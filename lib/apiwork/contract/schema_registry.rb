# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Contract
    # Registry maintaining Schema → Contract relationships
    # Stores explicit contracts for fast lookup
    #
    # Thread-safety: Lock-free using Concurrent::Map (atomic operations)
    class SchemaRegistry
      class << self
        def find(schema_class)
          registry.fetch_or_store(schema_class) do
            find_or_create_contract(schema_class)
          end
        end

        def register(schema_class, contract_class)
          registry[schema_class] = contract_class
        end

        # Clear registry (for development reload)
        def clear!
          @registry = Concurrent::Map.new
        end

        # For debugging/introspection
        def all
          registry.each_pair.to_h
        end

        private

        def find_or_create_contract(schema_class)
          # Try to find explicit contract class
          explicit = find_explicit_contract(schema_class)
          return explicit if explicit

          # No contract found - raise helpful error
          raise_missing_contract_error(schema_class)
        end

        def find_explicit_contract(schema_class)
          # Try naming convention: PostSchema → PostContract
          contract_name = schema_class.name.gsub(/Schema$/, 'Contract')
          contract_name.constantize
        rescue NameError
          nil
        end

        def raise_missing_contract_error(schema_class)
          contract_name = schema_class.name.gsub(/Schema$/, 'Contract')
          schema_name = schema_class.name.demodulize

          raise ConfigurationError,
                "No contract found for #{schema_class.name}.\n" \
                "Please create #{contract_name} with:\n\n" \
                "  class #{contract_name} < Apiwork::Contract::Base\n" \
                "    schema #{schema_name}\n" \
                '  end'
        end

        def registry
          @registry ||= Concurrent::Map.new
        end
      end

      # Initialize
      clear!
    end
  end
end
