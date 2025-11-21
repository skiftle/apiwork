# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Abstractable

      class << self
        attr_accessor :_schema_class

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@action_definitions, {})
          subclass.instance_variable_set(:@imports, {})
          subclass.instance_variable_set(:@configuration, {})
        end

        def schema(ref)
          # Validate that ref is a Class constant
          unless ref.is_a?(Class)
            raise ArgumentError, "schema must be a Class constant, got #{ref.class}. " \
                                 "Use: schema PostSchema (not 'PostSchema' or :post_schema)"
          end

          @_schema_class = ref

          # Register this explicit contract in the registry
          SchemaRegistry.register(ref, self)

          # Register enums from schema when contract is defined/reloaded
          # This ensures enums are available even if actions are cached
          Schema::TypeBuilder.build_contract_enums(self, ref)

          # nested_payload union is registered lazily via auto_import_association_contract
          # when a schema is used as a writable association, not eagerly here

          prepend Schema::Extension unless ancestors.include?(Schema::Extension)
        end

        # Explicitly register STI variant schemas for this contract's base schema
        # This ensures variant schemas are loaded before type generation, preventing
        # test isolation issues where variants aren't discovered in time.
        #
        # Example:
        #   class ClientContract < Apiwork::Contract::Base
        #     schema ClientSchema
        #     register_sti_variants PersonClientSchema, CompanyClientSchema
        #   end
        def register_sti_variants(*variant_schema_classes)
          variant_schema_classes.each do |variant_class|
            unless variant_class.is_a?(Class) && variant_class < Apiwork::Schema::Base
              raise ArgumentError,
                    "Expected Schema class, got #{variant_class.inspect}. " \
                    'Use: register_sti_variants PersonSchema, CompanySchema'
            end

            # Force load the variant schema class by accessing its name
            # This triggers Zeitwerk autoloading and causes the variant's
            # `variant` DSL to execute, registering it with the base schema
            variant_class.name
          end
        end

        # Get schema class
        def schema_class
          @_schema_class
        end

        # Check if this contract uses a schema
        def schema?
          @_schema_class.present?
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          builder = Descriptor::Builder.new(api_class: api_class, scope: self)
          builder.type(name, description: description, example: example, format: format, deprecated: deprecated, &block)
        end

        def enum(name, values, description: nil, example: nil, deprecated: false)
          builder = Descriptor::Builder.new(api_class: api_class, scope: self)
          builder.enum(name, values, description: description, example: example, deprecated: deprecated)
        end

        def union(name, &block)
          builder = Descriptor::Builder.new(api_class: api_class, scope: self)
          builder.union(name, &block)
        end

        # Configure contract-level settings
        #
        # @example
        #   configure do
        #     max_array_items 500
        #   end
        def configure(&block)
          return unless block

          @configuration ||= {}
          builder = Configuration::Builder.new(@configuration)
          builder.instance_eval(&block)
        end

        # Access configuration hash
        # @return [Hash] Contract configuration settings
        def configuration
          @configuration ||= {}
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
          Descriptor::Registry.resolve_type(type_name, contract_class: self, api_class: api_class)
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
