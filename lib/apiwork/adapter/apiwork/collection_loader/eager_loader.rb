# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class EagerLoader
          attr_reader :schema_class

          def self.perform(relation, schema_class, params)
            new(relation, schema_class).perform(params)
          end

          def initialize(relation, schema_class)
            @relation = relation
            @schema_class = schema_class
          end

          def perform(params)
            return @relation if schema_class.association_definitions.empty?

            includes_hash = IncludesResolver.new(schema: schema_class).build(params: params, for_collection: true)
            return @relation if includes_hash.empty?

            @relation.includes(includes_hash)
          end
        end
      end
    end
  end
end
