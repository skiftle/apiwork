# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Concerns::AbstractClass

      class << self
        attr_accessor :_schema_class

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@action_definitions, {})
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
            SchemaContractRegistry.register(ref, self)

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

        def action(action_name, replace: false, &block)
          @action_definitions ||= {}
          action_sym = action_name.to_sym

          action_definition = ActionDefinition.new(action_sym, self, replace: replace)
          action_definition.instance_eval(&block) if block_given?

          @action_definitions[action_sym] = action_definition
        end

        def resolve_custom_type(type_name, scope_id = :root)
          # scope_id can be :root (legacy) or a scope object (Definition, ActionDefinition)
          scope = scope_id == :root ? nil : scope_id
          Descriptors::Registry.resolve(type_name, contract_class: self, scope: scope)
        end

        # Get ActionDefinition for a specific action
        # Auto-generates actions if not explicitly defined and we have a resource
        # @param action_name [Symbol] Name of the action
        # @return [ActionDefinition, nil] The action definition or nil if not found
        def action_definition(action_name)
          @action_definitions ||= {}
          action_sym = action_name.to_sym

          # Return existing definition if present
          return @action_definitions[action_sym] if @action_definitions.key?(action_sym)

          # Auto-generate action if we have a schema (for any action, not just CRUD)
          if schema_class
            auto_generate_and_store_action(action_sym)
            return @action_definitions[action_sym]
          end

          nil
        end

        def action_definitions
          @action_definitions || {}
        end

        # Introspect entire contract or a specific action
        # When action is nil: Returns all actions with their input/output definitions
        # When action is provided: Returns input/output for that specific action
        # Only includes actions declared in API routing configuration (respects only:/except:)
        # @param action [Symbol, nil] Optional action name for specific action introspection
        # @return [Hash] Hash with :actions key (when action=nil) or :input/:output keys (when action provided)
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

        # Get API path for this contract based on namespace
        # Example: Api::V1::PostContract -> "/api/v1"
        # @return [String, nil] API path or nil if contract is anonymous
        def api_path
          return nil unless name # Anonymous classes don't have a name

          namespace_parts = name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          "/#{namespace_parts.map(&:underscore).join('/')}"
        end

        # Get API class for this contract
        # @return [Class, nil] API class or nil if not found
        def api_class
          path = api_path
          return nil unless path

          Apiwork::API.find(path)
        end

        # Get resource name for this contract
        # Example: PostContract -> :posts, PersonContract -> :people
        # @return [Symbol, nil] Resource name (pluralized) or nil if contract is anonymous
        def resource_name
          return nil unless name # Anonymous classes don't have a name

          name.demodulize.sub(/Contract$/, '').underscore.pluralize.to_sym
        end

        # Get resource metadata from API definition
        # @return [Hash, nil] Resource metadata or nil if not found
        def resource_metadata
          api = api_class
          return nil unless api&.metadata

          find_resource_in_metadata(api.metadata, resource_name)
        end

        # Get all available actions for this resource from API routing configuration
        # Includes CRUD actions (respecting only:/except:), member actions, and collection actions
        # @return [Array<Symbol>] Array of action names
        def available_actions
          metadata = resource_metadata
          return [] unless metadata

          actions = metadata[:actions] || []
          actions += metadata[:members]&.keys || []
          actions += metadata[:collections]&.keys || []
          actions
        end

        # Check if resource is singular (e.g., resource :profile vs resources :posts)
        # @return [Boolean] true if singular resource
        def singular_resource?
          resource_metadata&.dig(:singular) || false
        end

        def parse(data, direction, action, **options)
          Parser.new(new, direction, action, **options).perform(data)
        end

        private

        # Find resource in metadata, searching nested resources recursively
        # @param metadata [Metadata] API metadata object
        # @param resource_name [Symbol] Resource name to find
        # @return [Hash, nil] Resource metadata or nil if not found
        def find_resource_in_metadata(metadata, resource_name)
          MetadataSearcher.new(metadata).find_resource(resource_name)
        end
      end
    end
  end
end
