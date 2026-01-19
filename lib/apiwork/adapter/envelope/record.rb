# frozen_string_literal: true

module Apiwork
  module Adapter
    module Envelope
      class Record < Resource
        def root_key
          schema_class.root_key.singular
        end

        def render(data, state)
          { root_key => data, meta: state.meta.presence }.compact
        end
      end
    end
  end
end
