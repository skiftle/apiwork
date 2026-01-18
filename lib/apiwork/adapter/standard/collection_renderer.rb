# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class CollectionRenderer
        def call(result, schema_class, state)
          {
            schema_class.root_key.plural => result[:data],
            pagination: result[:metadata][:pagination],
            meta: state.meta.presence,
          }.compact
        end
      end
    end
  end
end
