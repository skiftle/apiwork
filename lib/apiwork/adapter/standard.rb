# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      option :pagination, type: :hash do
        option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
        option :default_size, default: 20, type: :integer
        option :max_size, default: 100, type: :integer
      end

      register do
        api APIBuilder
        contract ContractBuilder
      end

      request do
        before_validation do
          transform RequestTransformer
        end
        after_validation do
          transform OpFieldTransformer
        end
      end

      response do
        prepare do
          record RecordPreparer
          collection CollectionPreparer
        end

        render do
          record RecordRenderer
          collection CollectionRenderer
          error ErrorRenderer
        end
      end
    end
  end
end
