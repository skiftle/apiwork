# frozen_string_literal: true

module Apiwork
  module Adapter
    module Envelope
      class Resource < Base
        attr_reader :schema_class

        def initialize(schema_class)
          super()
          @schema_class = schema_class
        end

        def prepare(record, state)
          record
        end

        def serialize(record, state)
          include_param = state.request&.query&.dig(:include)
          schema_class.serialize(record, context: state.context, include: include_param)
        end
      end
    end
  end
end
