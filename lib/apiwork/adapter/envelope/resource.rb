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

        def define(registrar, actions); end

        def prepare_record(record, state)
          record
        end

        def serialize_record(record, serialize_options, state)
          schema_class.serialize(
            record,
            context: state.context,
            include: serialize_options[:include],
          )
        end

        def render_record(data, metadata, state)
          raise NotImplementedError
        end

        def prepare_collection(collection, state)
          collection
        end

        def serialize_collection(collection, serialize_options, state)
          schema_class.serialize(
            collection,
            context: state.context,
            include: serialize_options[:include],
          )
        end

        def render_collection(data, metadata, state)
          raise NotImplementedError
        end
      end
    end
  end
end
