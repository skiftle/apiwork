# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Base < Document::Base
          document_type :record

          attr_reader :capabilities, :meta, :metadata, :representation_class

          def initialize(data, representation_class, metadata, capabilities, meta)
            super(data)
            @representation_class = representation_class
            @metadata = metadata
            @capabilities = capabilities
            @meta = meta
          end

          def build
            json
          end
        end
      end
    end
  end
end
