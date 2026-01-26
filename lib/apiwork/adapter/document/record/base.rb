# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Base < Document::Base
          document_type :record

          attr_reader :capabilities, :data, :document, :meta, :representation_class

          def initialize(representation_class, data, document, capabilities, meta)
            super()
            @capabilities = capabilities
            @data = data
            @document = document
            @meta = meta
            @representation_class = representation_class
          end

          def build
            json.merge(document).compact
          end
        end
      end
    end
  end
end
