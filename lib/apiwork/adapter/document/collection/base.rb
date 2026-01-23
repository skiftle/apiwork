# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Base < Document::Base
          document_type :collection

          attr_reader :capabilities, :data, :document, :meta, :schema_class

          def initialize(schema_class, data, document, capabilities, meta)
            super()
            @capabilities = capabilities
            @data = data
            @document = document
            @meta = meta
            @schema_class = schema_class
          end

          def build
            json.merge(document).compact
          end
        end
      end
    end
  end
end
