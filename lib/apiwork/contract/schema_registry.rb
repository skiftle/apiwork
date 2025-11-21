# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Contract
    class SchemaRegistry
      class << self
        def find(schema_class)
          registry.fetch_or_store(schema_class) do
            find_contract(schema_class)
          end
        end

        def register(schema_class, contract_class)
          registry[schema_class] = contract_class
        end

        def clear!
          @registry = Concurrent::Map.new
        end

        def all
          registry.each_pair.to_h
        end

        private

        def find_contract(schema_class)
          contract_name = schema_class.name.gsub(/Schema$/, 'Contract')
          contract_name.constantize
        rescue NameError
          raise_missing_contract_error(schema_class)
        end

        def raise_missing_contract_error(schema_class)
          contract_name = schema_class.name.gsub(/Schema$/, 'Contract')
          schema_name = schema_class.name.demodulize

          raise ConfigurationError,
                "No contract found for #{schema_class.name}.\n" \
                "Apiwork requires an explicit contract class for every schema.\n\n" \
                "Create #{contract_name}:\n\n" \
                "  class #{contract_name} < Apiwork::Contract::Base\n" \
                "    schema #{schema_name}\n" \
                '  end'
        end

        def registry
          @registry ||= Concurrent::Map.new
        end
      end

      clear!
    end
  end
end
