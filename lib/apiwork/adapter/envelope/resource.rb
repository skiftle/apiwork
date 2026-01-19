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

        def define(registrar); end

        def prepare_record(record, state)
          record
        end

        def serialize_record(record, state)
          include_param = state.request.query[:include]
          schema_class.serialize(record, context: state.context, include: include_param)
        end

        def render_record(data, state)
          { schema_class.root_key.singular => data, meta: state.meta.presence }.compact
        end

        def prepare_collection(collection, state)
          { data: collection, metadata: {} }
        end

        def serialize_collection(collection, state)
          include_param = state.request.query[:include]
          schema_class.serialize(collection, context: state.context, include: include_param)
        end

        def render_collection(data, metadata, state)
          { schema_class.root_key.plural => data, **metadata, meta: state.meta.presence }.compact
        end
      end
    end
  end
end
