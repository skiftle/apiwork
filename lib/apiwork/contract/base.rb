# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Abstractable

      class_attribute :action_definitions, instance_accessor: false
      class_attribute :imports, instance_accessor: false
      class_attribute :configuration, instance_accessor: false
      class_attribute :_identifier
      class_attribute :_schema_class

      class << self
        def inherited(subclass)
          super
          subclass.action_definitions = {}
          subclass.imports = {}
          subclass.configuration = {}
        end

        # DOCUMENTATION
        def identifier(value = nil)
          return _identifier if value.nil?

          self._identifier = value.to_s
        end

        # DOCUMENTATION
        def schema(ref)
          unless ref.is_a?(Class)
            raise ArgumentError, "schema must be a Class constant, got #{ref.class}. " \
                                 "Use: schema PostSchema (not 'PostSchema' or :post_schema)"
          end

          self._schema_class = ref

          SchemaRegistry.register(ref, self)

          Schema::TypeBuilder.build_contract_enums(self, ref)

          prepend Schema::Extension unless ancestors.include?(Schema::Extension)
        end

        def register_sti_variants(*variant_schema_classes)
          variant_schema_classes.each do |variant_class|
            unless variant_class.is_a?(Class) && variant_class < Apiwork::Schema::Base
              raise ArgumentError,
                    "Expected Schema class, got #{variant_class.inspect}. " \
                    'Use: register_sti_variants PersonSchema, CompanySchema'
            end

            variant_class.name
          end
        end

        def schema_class
          _schema_class
        end

        # DOCUMENTATION
        def schema?
          _schema_class.present?
        end

        # DOCUMENTATION
        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          Descriptor.define_type(
            name,
            api_class: api_class,
            scope: self,
            description: description,
            example: example,
            format: format,
            deprecated: deprecated,
            &block
          )
        end

        # DOCUMENTATION
        def enum(name, values:, description: nil, example: nil, deprecated: false)
          Descriptor.define_enum(
            name,
            values: values,
            api_class: api_class,
            scope: self,
            description: description,
            example: example,
            deprecated: deprecated
          )
        end

        # DOCUMENTATION
        def union(name, &block)
          Descriptor.define_union(name, api_class: api_class, scope: self, &block)
        end

        # DOCUMENTATION
        def configure(&block)
          return unless block

          builder = Configuration::Builder.new(configuration)
          builder.instance_eval(&block)
        end

        # DOCUMENTATION
        def import(contract_class, as:)
          unless contract_class.is_a?(Class)
            raise ArgumentError, "import must be a Class constant, got #{contract_class.class}. " \
                                 "Use: import UserContract, as: :user (not 'UserContract' or :user_contract)"
          end

          unless contract_class < Apiwork::Contract::Base
            raise ArgumentError, 'import must be a Contract class (subclass of Apiwork::Contract::Base), ' \
                                 "got #{contract_class}"
          end

          unless as.is_a?(Symbol)
            raise ArgumentError, "import alias must be a Symbol, got #{as.class}. " \
                                 'Use: import UserContract, as: :user'
          end

          imports[as] = contract_class
        end

        # DOCUMENTATION
        def action(action_name, replace: false, &block)
          action_name_sym = action_name.to_sym

          action_definition = ActionDefinition.new(action_name: action_name_sym, contract_class: self, replace: replace)
          action_definition.instance_eval(&block) if block_given?

          action_definitions[action_name_sym] = action_definition
        end

        def resolve_custom_type(type_name)
          Descriptor.resolve_type(type_name, contract_class: self, api_class: api_class)
        end

        def action_definition(action_name)
          action_name_sym = action_name.to_sym

          return action_definitions[action_name_sym] if action_definitions.key?(action_name_sym)

          if schema_class
            auto_generate_and_store_action(action_name_sym)
            return action_definitions[action_name_sym]
          end

          nil
        end

        # DOCUMENTATION
        def introspect(action = nil)
          if action
            action_def = action_definition(action)
            return nil unless action_def

            action_def.as_json
          else
            result = { actions: {} }

            actions = available_actions

            actions = action_definitions.keys if actions.empty?

            actions.each do |action_name|
              action_def = action_definition(action_name)
              result[:actions][action_name] = action_def.as_json if action_def
            end

            result
          end
        end

        def as_json
          introspect
        end

        def api_path
          return nil unless name

          namespace_parts = name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          "/#{namespace_parts.map(&:underscore).join('/')}"
        end

        def api_class
          path = api_path
          return nil unless path

          Apiwork::API.find(path)
        end

        def resource_name
          return nil unless name

          name.demodulize.sub(/Contract$/, '').underscore.pluralize.to_sym
        end

        def resource_metadata
          api = api_class
          return nil unless api&.metadata

          api.metadata.find_resource(resource_name)
        end

        def available_actions
          metadata = resource_metadata
          return [] unless metadata

          actions = metadata[:actions]&.keys || []
          actions += metadata[:members]&.keys || []
          actions += metadata[:collections]&.keys || []
          actions
        end

        def singular_resource?
          resource_metadata&.dig(:singular) || false
        end

        # DOCUMENTATION
        def parse(data, direction, action, **options)
          Parser.new(self, direction, action, **options).perform(data)
        end

        # DOCUMENTATION
        def format_keys(data, direction)
          return data if data.blank?

          setting = direction == :output ? :output_key_format : :input_key_format
          key_format = Configuration::Resolver.resolve(setting, contract_class: self)

          return data unless key_format

          case key_format
          when :camel
            data.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          when :underscore
            data.deep_transform_keys { |key| key.to_s.underscore.to_sym }
          else
            data
          end
        end
      end
    end
  end
end
