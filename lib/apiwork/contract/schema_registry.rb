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
        rescue NameError
          nil
        end

        def create_anonymous_contract(schema_class)
          # Create anonymous contract ONLY when no explicit contract exists
          # Derive API class from schema namespace
          api_class_for_schema = derive_api_class_from_schema(schema_class)

          contract = Class.new(Base) do
            @_schema_class = schema_class
            prepend Schema::Extension

            define_singleton_method(:name) do
              "#{schema_class.name.gsub(/Schema$/, 'Contract')}(Generated)"
            end

            define_singleton_method(:inspect) do
              name
            end

            # Override api_class to use schema's namespace
            define_singleton_method(:api_class) do
              api_class_for_schema
            end
          end

          # Register enums for anonymous contracts
          Schema::TypeRegistry.register_contract_enums(contract, schema_class)

          contract
        end

        # Derive API class from schema class namespace
        # Example: Api::V1::AccountSchema → /api/v1 → finds API class
        def derive_api_class_from_schema(schema_class)
          return nil unless schema_class.name

          namespace_parts = schema_class.name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          api_path = "/#{namespace_parts.map(&:underscore).join('/')}"
          Apiwork::API.find(api_path)
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
