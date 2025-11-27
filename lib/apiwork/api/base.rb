# frozen_string_literal: true

module Apiwork
  module API
    class Base
      class << self
        attr_reader :adapter_config,
                    :metadata,
                    :mount_path,
                    :namespaces,
                    :recorder,
                    :specs

        def mount(path)
          @mount_path = path
          @specs = {}
          @contracts_built_for = Set.new

          @namespaces = path == '/' ? [:root] : path.split('/').reject(&:empty?).map(&:to_sym)

          @metadata = Metadata.new(path)
          @recorder = Recorder.new(@metadata, @namespaces)

          Registry.register(self)

          @adapter_config = {}
        end

        def contracts_built_for
          @contracts_built_for ||= Set.new
        end

        def spec(type, path: nil)
          unless Generator::Registry.registered?(type)
            available = Generator::Registry.all.join(', ')
            raise ConfigurationError,
                  "Unknown spec generator: :#{type}. " \
                  "Available generators: #{available}"
          end

          @specs ||= {}

          path ||= "/.spec/#{type}"

          @specs[type] = path
        end

        def specs?
          @specs&.any?
        end

        def error_codes(*codes)
          @metadata.error_codes = codes.flatten.map(&:to_i).uniq.sort
        end

        def adapter(name = nil, &block)
          if name.is_a?(Symbol)
            @adapter_name = name
            @adapter_instance = nil
          end

          if block
            @adapter_config ||= {}
            adapter_class = Adapter.resolve(@adapter_name || :apiwork)
            builder = Adapter::Configuration.new(adapter_class, @adapter_config)
            builder.instance_eval(&block)
            return
          end

          @adapter ||= Adapter.resolve(@adapter_name || :apiwork).new
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          Descriptor.define_type(
            name,
            api_class: self,
            description: description,
            example: example,
            format: format,
            deprecated: deprecated,
            &block
          )
        end

        def enum(name, values:, description: nil, example: nil, deprecated: false)
          Descriptor.define_enum(
            name,
            values: values,
            api_class: self,
            description: description,
            example: example,
            deprecated: deprecated
          )
        end

        def union(name, &block)
          Descriptor.define_union(name, api_class: self, &block)
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

        def introspect
          ensure_all_contracts_built!
          @introspect ||= Apiwork::Introspection.api(self)
        end

        def as_json
          introspect
        end

        def ensure_contract_built!(contract_class)
          return if contracts_built_for.include?(contract_class.name)

          contracts_built_for.add(contract_class.name)

          resource_data = find_resource_for_contract(contract_class)
          return unless resource_data

          schema_class = contract_class.schema_class
          return unless schema_class

          actions = extract_actions_from_resource(resource_data)
          adapter.build_contract(contract_class, schema_class, actions: actions)
        end

        def ensure_all_contracts_built!
          return unless @metadata

          @metadata.resources.each_value do |resource_data|
            build_contracts_for_resource(resource_data)
          end

          schemas = collect_all_schemas
          schema_data = Adapter::SchemaData.new(schemas)
          adapter.build_global_descriptors(Descriptor::Builder.new(api_class: self), schema_data)
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
          return if contracts_built_for.include?(contract_class.name)

          schema_class = contract_class.schema_class
          return unless schema_class

          actions = extract_actions_from_resource(resource_data)
          adapter.build_contract(contract_class, schema_class, actions: actions)
          contracts_built_for.add(contract_class.name)

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
      end
    end
  end
end
