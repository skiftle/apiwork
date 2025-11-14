# frozen_string_literal: true

module Apiwork
  module Contract
    # Registry maintaining Schema → Contract relationships
    # Stores anonymous contracts and explicit contracts for fast lookup
    #
    # Priority:
    # 1. Explicit contract (e.g., PostContract) if exists
    # 2. Anonymous contract (generated) if no explicit contract
    #
    # Thread-safety: Optimistic lazy creation (harmless races)
    class SchemaRegistry
      class << self
        def contract_for_schema(schema_class)
          # Return cached if exists (thread-safe read)
          @registry[schema_class] ||= find_or_create_contract(schema_class)
        end

        def register(schema_class, contract_class)
          @registry[schema_class] = contract_class
        end

        # Clear registry (for development reload)
        def clear!
          @registry = {}
        end

        # For debugging/introspection
        def all
          @registry.dup
        end

        private

        def find_or_create_contract(schema_class)
          # FIRST: Try to find explicit contract class
          explicit = find_explicit_contract(schema_class)
          return explicit if explicit

          # ONLY IF NOT FOUND: Create anonymous
          create_anonymous_contract(schema_class)
        end

        def find_explicit_contract(schema_class)
          # Try naming convention: PostSchema → PostContract
          contract_name = schema_class.name.gsub(/Schema$/, 'Contract')
          contract_name.constantize
        rescue NameError => e
          Rails.logger&.debug("No explicit contract found for #{schema_class.name}: #{e.message}") if defined?(Rails)
          nil
        end

        def create_anonymous_contract(schema_class)
          # Create anonymous contract ONLY when no explicit contract exists
          Class.new(Base) do
            @_schema_class = schema_class
            prepend Schema::Extension

            define_singleton_method(:name) do
              "#{schema_class.name.gsub(/Schema$/, 'Contract')}(Generated)"
            end

            define_singleton_method(:inspect) do
              name
            end
          end
        end

        def registry
          @registry ||= {}
        end
      end

      # Initialize
      clear!
    end
  end
end
