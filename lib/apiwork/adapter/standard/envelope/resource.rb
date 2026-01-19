# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Resource < Adapter::Envelope::Resource
          def define(registrar); end

          def prepare_record(record, state)
            Validator.validate!(record, schema_class)
            Loader.load(record, schema_class, state.request)
          end

          def render_record(data, state)
            {
              schema_class.root_key.singular => data,
              meta: state.meta.presence,
            }.compact
          end

          def prepare_collection(collection, state)
            { data: collection, metadata: {} }
          end

          def render_collection(data, metadata, state)
            {
              schema_class.root_key.plural => data,
              pagination: metadata[:pagination],
              meta: state.meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
