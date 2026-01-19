# frozen_string_literal: true

module Apiwork
  module Adapter
    module Envelope
      class Collection < Resource
        def root_key
          schema_class.root_key.plural
        end

        def render(data, metadata, state)
          { root_key => data, **metadata, meta: state.meta.presence }.compact
        end
      end
    end
  end
end
