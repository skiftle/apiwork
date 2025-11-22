# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Abstractable

      class << self
        attr_accessor :_identifier,
                      :_schema_class

        def identifier(value = nil)
          return @_identifier if value.nil?

          @_identifier = value.to_s
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@action_definitions, {})
          subclass.instance_variable_set(:@imports, {})
          subclass.instance_variable_set(:@configuration, {})
        end

        def schema(ref)
          unless ref.is_a?(Class)
            raise ArgumentError, "schema must be a Class constant, got #{ref.class}. " \
                                 "Use: schema PostSchema (not 'PostSchema' or :post_schema)"
          end

          @_schema_class = ref

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
          @_schema_class
        end

        def schema?
          @_schema_class.present?
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          Descriptor::Builder.define_type(
            api_class: api_class,
            scope: self,
            name: name,
            description: description,
            example: example,
            format: format,
            deprecated: deprecated,
            &block
          )
        end

        def enum(name, values:, description: nil, example: nil, deprecated: false)
          Descriptor::Builder.define_enum(
            api_class: api_class,
            scope: self,
            name: name,
            values: values,
            description: description,
            example: example,
            deprecated: deprecated
          )
        end

        def union(name, &block)
          Descriptor::Builder.define_union(api_class: api_class, scope: self, name: name, &block)
        end

        def configure(&block)
          return unless block

          @configuration ||= {}
          builder = Configuration::Builder.new(@configuration)
          builder.instance_eval(&block)
        end

        def configuration
          @configuration ||= {}
        end

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

          @imports ||= {}
          @imports[as] = contract_class
        end

        def imports
          @imports || {}
        end

        def action(action_name, replace: false, &block)
          @action_definitions ||= {}
          action_name_sym = action_name.to_sym

          action_definition = ActionDefinition.new(action_name: action_name_sym, contract_class: self, replace: replace)
          action_definition.instance_eval(&block) if block_given?

          @action_definitions[action_name_sym] = action_definition
        end

        def resolve_custom_type(type_name)
          Descriptor::Registry.resolve_type(type_name, contract_class: self, api_class: api_class)
        end

        def action_definition(action_name)
          @action_definitions ||= {}
          action_name_sym = action_name.to_sym

          return @action_definitions[action_name_sym] if @action_definitions.key?(action_name_sym)

          if schema_class
            auto_generate_and_store_action(action_name_sym)
            return @action_definitions[action_name_sym]
          end

          nil
        end

        def action_definitions
          @action_definitions || {}
        end

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

        def parse(data, direction, action, **options)
          Parser.new(self, direction, action, **options).perform(data)
        end
      end
    end
  end
end
