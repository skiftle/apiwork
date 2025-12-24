# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      class CollectionLoader
        class EagerLoader
          attr_reader :schema_class

          def self.load(relation, schema_class, params)
            new(relation, schema_class).load(params)
          end

          def initialize(relation, schema_class)
            @relation = relation
            @schema_class = schema_class
          end

          def load(params)
            return @relation if schema_class.association_definitions.empty?

            includes_hash = IncludesResolver.new(schema_class).build(params: params, for_collection: true)
            return @relation if includes_hash.empty?

            @relation.includes(includes_hash)
          end
        end
      end
    end
  end
end
