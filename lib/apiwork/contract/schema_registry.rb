# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Contract
    class SchemaRegistry
      class << self
        def register(schema_class:, contract_class:)
          return unless schema_class && contract_class

          contracts_for_schema = contracts[schema_class] || []
          contracts[schema_class] = (contracts_for_schema + [contract_class]).uniq
        end

        def find(schema_class)
          contracts[schema_class]&.first
        end

        def all_for_schema(schema_class)
          contracts[schema_class] || []
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
