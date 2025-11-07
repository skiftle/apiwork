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

        def parse(data, direction, action, **options)
          Parser.new(new, direction, action, **options).perform(data)
        end
      end
    end
  end
end
