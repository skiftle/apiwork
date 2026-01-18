# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class CollectionPreparer
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
              return @relation if schema_class.associations.empty?

              includes_hash = IncludesResolver.new(schema_class).build(params:, for_collection: true)
              return @relation if includes_hash.empty?

              @relation.includes(includes_hash)
            end
          end
        end
      end
    end
  end
end
