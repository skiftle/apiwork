# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Record < Adapter::Envelope::Record
          def prepare(record, state)
            RecordValidator.validate!(record, schema_class)
            RecordLoader.load(record, schema_class, state.request)
          end

          def render(data, state)
            {
              schema_class.root_key.singular => data,
              meta: state.meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
