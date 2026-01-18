# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class CollectionPreparer
        def call(collection, schema_class, state)
          CollectionLoader.load(collection, schema_class, state)
        end

        class CollectionLoader; end
      end
    end
  end
end
