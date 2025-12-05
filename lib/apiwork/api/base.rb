# frozen_string_literal: true

module Apiwork
  module API
    class Base
      class << self
        attr_reader :adapter_config,
                    :built_contracts,
                    :metadata,
                    :mount_path,
                    :namespaces,
                    :recorder,
                    :spec_configs,
                    :specs,
                    :type_system

        def mount(path)
          @mount_path = path
          @specs = Set.new
          @spec_configs = {}
          @type_system = TypeSystem.new
          @built_contracts = Set.new
          @key_format = :keep

          @namespaces = path == '/' ? [] : path.split('/').reject(&:empty?).map { |n| n.tr('-', '_').to_sym }

          @metadata = Metadata.new(path)
          @recorder = Recorder.new(@metadata, @namespaces)

          Registry.register(self)

          @adapter_config = {}
        end

        def key_format(format = nil)
          return @key_format if format.nil?

          valid = %i[keep camel underscore]
          raise ConfigurationError, "key_format must be one of #{valid}" unless valid.include?(format)

          @key_format = format
        end

        def transform_request(hash)
          transform_request_keys(hash)
        end

        def transform_response(hash)
          transform_response_keys(hash)
        end

        private

        def transform_request_keys(hash)
          case @key_format
          when :camel
            hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
          else
            hash
          end
        end

        def transform_response_keys(hash)
          case @key_format
          when :camel
            hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          else
            hash
          end
        end

        public

        def spec(type, &block)
          unless Spec::Registry.registered?(type)
            available = Spec::Registry.all.join(', ')
            raise ConfigurationError,
                  "Unknown spec: :#{type}. " \
                  "Available: #{available}"
          end

          @specs ||= Set.new
          @spec_configs ||= {}

          @specs.add(type)
          @spec_configs[type] ||= {}
          @spec_configs[type][:path] ||= "/.spec/#{type}"

          return unless block

          spec_class = Spec::Registry.find(type)
          builder = Configuration::Builder.new(spec_class, @spec_configs[type])
          builder.instance_eval(&block)
        end

        def spec_path(type)
          @spec_configs&.dig(type, :path) || "/.spec/#{type}"
        end

        def spec_config(type)
          @spec_configs&.[](type) || {}
        end

        def specs?
          @specs&.any?
        end

        def raises(*error_code_keys)
          error_code_keys = error_code_keys.flatten.uniq
          error_code_keys.each do |error_code_key|
            unless error_code_key.is_a?(Symbol)
              hint = error_code_key.is_a?(Integer) ? " Use :#{ErrorCode.key_for_status(error_code_key)} instead." : ''
              raise ConfigurationError, "raises must be symbols, got #{error_code_key.class}: #{error_code_key}.#{hint}"
            end

            next if ErrorCode.registered?(error_code_key)

            raise ConfigurationError,
                  "Unknown error code :#{error_code_key}. Register it with: " \
                  "Apiwork::ErrorCode.register :#{error_code_key}, status: <status>"
          end
          @metadata.raises = error_code_keys
        end

        def adapter(name = nil, &block)
          if name.is_a?(Symbol)
            @adapter_name = name
            @adapter_instance = nil
          end

          if block
            @adapter_config ||= {}
            adapter_class = Adapter.find(@adapter_name || :apiwork)
            builder = Configuration::Builder.new(adapter_class, @adapter_config)
            builder.instance_eval(&block)
            return
          end

          @adapter ||= Adapter.find(@adapter_name || :apiwork).new
        end

        def type(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false,
                 schema_class: nil, &block)
          type_system.register_type(name, scope:, description:, example:, format:, deprecated:,
                                          schema_class:, &block)
        end

        def enum(name, values: nil, scope: nil, description: nil, example: nil, deprecated: false)
          raise ArgumentError, 'Values must be an array' if values && !values.is_a?(Array)

          type_system.register_enum(name, values, scope:, description:, example:, deprecated:)
        end

        def union(name, scope: nil, discriminator: nil, &block)
          raise ArgumentError, 'Union requires a block' unless block_given?

          union_builder = TypeSystem::UnionBuilder.new(discriminator:)
          union_builder.instance_eval(&block)
          type_system.register_union(name, union_builder.serialize, scope:)
        end

        def resolve_type(name, scope: nil)
          type_system.resolve_type(name, scope:)
        end

        def resolve_enum(name, scope:)
          type_system.resolve_enum(name, scope:)
        end

        def scoped_name(scope, name)
          type_system.scoped_name(scope, name)
        end

        def info(&block)
          builder = Info::Builder.new
          builder.instance_eval(&block)
          @metadata.info = builder.info
        end

        def resources(name, **options, &block)
          @recorder.resources(name, **options, &block)
        end

        def resource(name, **options, &block)
          @recorder.resource(name, **options, &block)
        end

        def concern(name, &block)
          @recorder.concern(name, &block)
        end

        def with_options(options = {}, &block)
          @recorder.with_options(options, &block)
        end

        def introspect(locale: nil)
          ensure_all_contracts_built!
          @introspect_cache ||= {}
          @introspect_cache[locale] ||= Apiwork::Introspection.api(self, locale:)
        end

        def as_json
          introspect
        end

        def reset_contracts!
          @built_contracts = Set.new
        end

        def ensure_contract_built!(contract_class)
          return if built_contracts.include?(contract_class)

          resource_data = find_resource_for_contract(contract_class)
          return unless resource_data

          schema_class = contract_class.schema_class
          return unless schema_class

          built_contracts.add(contract_class)

          actions = extract_actions_from_resource(resource_data)
          type_registrar = adapter.build_contract_type_registrar(contract_class)
          adapter.register_contract_types(type_registrar, schema_class, actions: actions)
        end

        def ensure_all_contracts_built!
          return unless @metadata

          @metadata.resources.each_value do |resource_data|
            build_contracts_for_resource(resource_data)
          end

          schemas = collect_all_schemas
          has_resources = @metadata.resources.any?
          has_index_actions = any_index_actions?(@metadata.resources)
          schema_data = adapter.build_schema_data(schemas, has_resources:, has_index_actions:)
          type_registrar = adapter.build_api_type_registrar(self)
          adapter.register_api_types(type_registrar, schema_data)
        end

        private

        def find_resource_for_contract(contract_class)
          @metadata&.search_resources do |resource_data|
            resource_data if resource_data[:contract] == contract_class.name ||
                             resource_data[:contract_class] == contract_class
          end
        end

        def build_contracts_for_resource(resource_data)
          contract_class = @metadata.resolve_contract_class(resource_data)
          return unless contract_class
          return if built_contracts.include?(contract_class)

          schema_class = contract_class.schema_class
          return unless schema_class

          built_contracts.add(contract_class)

          actions = extract_actions_from_resource(resource_data)
          type_registrar = adapter.build_contract_type_registrar(contract_class)
          adapter.register_contract_types(type_registrar, schema_class, actions: actions)

          resource_data[:resources]&.each_value do |nested_resource|
            build_contracts_for_resource(nested_resource)
          end
        end

        def collect_all_schemas
          schemas = []
          collect_schemas_recursive(@metadata.resources, schemas)
          schemas.compact
        end

        def collect_schemas_recursive(resources, schemas)
          resources.each_value do |resource_data|
            contract_class = @metadata.resolve_contract_class(resource_data)
            schema_class = contract_class&.schema_class
            schemas << schema_class if schema_class
            collect_schemas_recursive(resource_data[:resources] || {}, schemas)
          end
        end

        def extract_actions_from_resource(resource_data)
          actions = {}

          resource_data[:only]&.each do |action_name|
            type = %i[index].include?(action_name) ? :collection : :member
            method = action_method_for(action_name)

            actions[action_name] = { type: type, method: method }
          end

          resource_data[:members]&.each do |action_name, action_data|
            actions[action_name] = { type: :member, method: action_data[:method] }
          end

          resource_data[:collections]&.each do |action_name, action_data|
            actions[action_name] = { type: :collection, method: action_data[:method] }
          end

          actions
        end

        def action_method_for(action_name)
          case action_name.to_sym
          when :index then :get
          when :show then :get
          when :create then :post
          when :update then :patch
          when :destroy then :delete
          else :get
          end
        end

        def any_index_actions?(resources)
          resources.any? do |_, resource_data|
            resource_has_index?(resource_data)
          end
        end

        def resource_has_index?(resource_data)
          return true if resource_data[:only]&.include?(:index)

          resource_data[:resources]&.any? { |_, nested| resource_has_index?(nested) }
        end
      end
    end
  end
end
