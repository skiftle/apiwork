# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Concerns::AbstractClass

      class << self
        attr_accessor :_schema_class

        def inherited(subclass)
          super
          # Initialize action definitions hash for each subclass
          subclass.instance_variable_set(:@action_definitions, {})
          # Initialize custom types hash for each subclass
          subclass.instance_variable_set(:@custom_types, {})
        end

        def schema(ref = nil)
          if ref
            # Validate that ref is a Class constant
            unless ref.is_a?(Class)
              raise ArgumentError, "schema must be a Class constant, got #{ref.class}. " \
                                   "Use: schema PostSchema (not 'PostSchema' or :post_schema)"
            end

            @_schema_class = ref

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

        # DSL method to define a custom type
        # Supports lexical scoping - types can be defined at contract, action, or input/output level
        #
        # THREADING NOTES:
        # This method uses Thread.current[:apiwork_type_scope] to maintain lexical scope
        # during DSL evaluation (instance_eval). This is safe because:
        # - Rails request processing is single-threaded per request
        # - Contract definitions happen at boot time, also single-threaded
        # - The scope is set/unset within the same method call (proper cleanup)
        # - No state persists across requests
        #
        # If using async request processing (e.g., Falcon), ensure contract
        # definitions complete before serving requests. Runtime type resolution
        # is thread-safe as it only reads immutable @type_scopes.
        #
        # @param name [Symbol] Name of the custom type
        # @param block [Proc] Block defining the type's parameters
        def type(name, &block)
          raise ArgumentError, 'Block required for custom type definition' unless block_given?

          # Get current scope (set by ActionDefinition or Definition during instance_eval)
          current_scope = Thread.current[:apiwork_type_scope] || :root

          # Initialize scope storage
          @type_scopes ||= {}
          @type_scopes[current_scope] ||= {}

          # Register type in current scope (shadowing allowed)
          @type_scopes[current_scope][name] = block
        end

        # Get custom types hash (legacy - returns root scope only)
        # @return [Hash] Hash of custom type names to blocks at root level
        def custom_types
          @type_scopes ||= {}
          @type_scopes[:root] || {}
        end

        # Resolve a custom type by searching scope chain
        # @param type_name [Symbol] Name of the type to resolve
        # @param scope_id [Symbol] Current scope identifier
        # @return [Proc, nil] The type block or nil if not found
        def resolve_custom_type(type_name, scope_id = :root)
          @type_scopes ||= {}
          @scope_parents ||= {}

          # Search scope chain: current → parent → root
          current = scope_id
          while current
            return @type_scopes.dig(current, type_name) if @type_scopes.dig(current, type_name)

            current = @scope_parents[current]
          end

          nil
        end

        # Register a scope with its parent for chain resolution
        # @param scope_id [Symbol] The scope identifier
        # @param parent_scope [Symbol] The parent scope identifier
        def register_scope(scope_id, parent_scope = :root)
          @scope_parents ||= {}
          @scope_parents[scope_id] = parent_scope
        end

        # Get all scopes (for debugging)
        def type_scopes
          @type_scopes || {}
        end

        # DSL method to define an action
        # @param action_name [Symbol] Name of the action (:index, :show, :create, etc.)
        # @param block [Proc] Block to configure the action (merges with auto-generated if standard CRUD)
        def action(action_name, &block)
          @action_definitions ||= {}
          action_sym = action_name.to_sym

          # Create action definition
          action_definition = ActionDefinition.new(action_sym, self)

          # Apply custom block with action scope
          if block_given?
            action_scope_id = :"action_#{action_sym}"
            register_scope(action_scope_id, :root)

            # Set scope for this action block
            previous_scope = Thread.current[:apiwork_type_scope]
            Thread.current[:apiwork_type_scope] = action_scope_id

            begin
              action_definition.instance_eval(&block)
            ensure
              # Restore previous scope
              Thread.current[:apiwork_type_scope] = previous_scope
            end
          end

          @action_definitions[action_sym] = action_definition
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

        # Serialize entire contract to JSON-friendly hash
        # Returns all actions with their input/output definitions
        # Only includes actions declared in API routing configuration (respects only:/except:)
        # @return [Hash] Hash with :actions key containing all action definitions
        def as_json
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

        # Get introspection for a specific action
        # @param action [Symbol] Action name
        # @return [Hash] Hash with :input and :output definitions for the action
        def introspection(action)
          action_def = action_definition(action)
          return nil unless action_def

          action_def.as_json
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
          actions += (metadata[:members]&.keys || [])
          actions += (metadata[:collections]&.keys || [])
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
          # Check top-level resources
          return metadata.resources[resource_name] if metadata.resources[resource_name]

          # Search nested resources recursively
          metadata.resources.each_value do |resource_metadata|
            found = find_resource_recursive(resource_metadata, resource_name)
            return found if found
          end

          nil
        end

        # Recursively search for resource in nested resource tree
        # @param resource_metadata [Hash] Current resource metadata
        # @param resource_name [Symbol] Resource name to find
        # @return [Hash, nil] Resource metadata or nil if not found
        def find_resource_recursive(resource_metadata, resource_name)
          return resource_metadata[:resources][resource_name] if resource_metadata[:resources]&.key?(resource_name)

          resource_metadata[:resources]&.each_value do |nested_metadata|
            found = find_resource_recursive(nested_metadata, resource_name)
            return found if found
          end

          nil
        end
      end
    end
  end
end
