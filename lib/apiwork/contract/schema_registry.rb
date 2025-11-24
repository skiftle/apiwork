# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Contract
    class SchemaRegistry
      class << self
        def register(schema_class:, contract_class:)
          return unless schema_class && contract_class

          existing = contracts[schema_class]
          if existing && existing != contract_class
            raise ArgumentError,
                  "Schema #{schema_class.name} is already registered to #{existing.name}. " \
                  'Each schema can only be associated with one contract. ' \
                  "Cannot register #{contract_class.name}."
          end

          contracts[schema_class] = contract_class
        end

        def find(schema_class)
          contracts[schema_class]
        end

        def clear!
          @contracts = Concurrent::Map.new
        end

        private

        def contracts
          @contracts ||= Concurrent::Map.new
        end
      end
    end
  end
end
