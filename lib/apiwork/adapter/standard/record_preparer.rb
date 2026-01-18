# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class RecordPreparer
        def call(record, schema_class, state)
          RecordValidator.validate!(record, schema_class)
          RecordLoader.load(record, schema_class, state.request)
        end

        class RecordValidator; end
        class RecordLoader; end
      end
    end
  end
end
