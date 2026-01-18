# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class RecordRenderer
        def call(data, schema_class, state)
          {
            schema_class.root_key.singular => data,
            meta: state.meta.presence,
          }.compact
        end
      end
    end
  end
end
