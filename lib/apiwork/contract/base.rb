# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Concerns::AbstractClass

      class << self
        attr_accessor :_schema_class, :_identifier

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@action_definitions, {})
          subclass.instance_variable_set(:@imports, {})
        end

        def identifier(value = nil)
          if value
            @_identifier = value.to_s
            value
          else
            @_identifier
          end
        end

        def schema(ref = nil)
          if ref
            # Validate that ref is a Class constant
            unless ref.is_a?(Class)
              raise ArgumentError, "schema must be a Class constant, got #{ref.class}. " \
                                   "Use: schema PostSchema (not 'PostSchema' or :post_schema)"
            end

            @_schema_class = ref

            # Register this explicit contract in the registry
            # This ensures schema.contract returns this class, not an anonymous one
            SchemaRegistry.register(ref, self)

            prepend Schema::Extension unless ancestors.include?(Schema::Extension)
          else
            # Getting schema
            @_schema_class
          end
        end

        # Get schema class
        def schema_class
          @_schema_class
        end

        # Check if this contract uses a schema
        def schema?
          !@_schema_class.nil?
        end

        def type(name, &block)
          raise ArgumentError, 'Block required for custom type definition' unless block_given?

          Descriptors::Registry.register_local(self, name, &block)
        end

        def enum(name, values)
          raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

          Descriptors::Registry.register_local_enum(self, name, values)
        end

        def import(contract_class, as:)
          # Validate contract_class is a Class
          unless contract_class.is_a?(Class)
            raise ArgumentError, "import must be a Class constant, got #{contract_class.class}. " \
                                 "Use: import UserContract, as: :user (not 'UserContract' or :user_contract)"
          end

          # Validate contract_class is a Contract
          unless contract_class < Apiwork::Contract::Base
            raise ArgumentError, 'import must be a Contract class (subclass of Apiwork::Contract::Base), ' \
                                 "got #{contract_class}"
          end

          # Validate alias is a symbol
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
          Descriptors::Registry.resolve(type_name, contract_class: self)
        end

        def action_definition(action_name)
          @action_definitions ||= {}
          action_name_sym = action_name.to_sym

          # Return existing definition if present
          return @action_definitions[action_name_sym] if @action_definitions.key?(action_name_sym)

          # Auto-generate action if we have a schema (for any action, not just CRUD)
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
            # Specific action introspection
            action_def = action_definition(action)
            return nil unless action_def

            action_def.as_json
          else
            # Full contract introspection
            result = { actions: {} }

            # Get available actions from API routing configuration
            actions = available_actions

            # If no API definition found, fall back to all explicit action definitions
            actions = action_definitions.keys if actions.empty?

            # Serialize only available actions
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
          return nil unless name # Anonymous classes don't have a name

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
          return nil unless name # Anonymous classes don't have a name

          name.demodulize.sub(/Contract$/, '').underscore.pluralize.to_sym
        end

        def resource_metadata
          api = api_class
          return nil unless api&.metadata

          find_resource_in_metadata(api.metadata, resource_name)
        end

        def available_actions
          metadata = resource_metadata
          return [] unless metadata

          actions = metadata[:actions] || []
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

        private

        def find_resource_in_metadata(metadata, resource_name)
          MetadataSearcher.new(metadata).find_resource(resource_name)
        end
      end
    end
  end
end
