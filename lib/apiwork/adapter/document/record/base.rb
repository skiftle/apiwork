# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Base < Document::Base
          document_type :record

          attr_reader :capabilities, :meta, :metadata, :root_key

          def initialize(data, root_key, metadata, capabilities, meta)
            super(data)
            @root_key = root_key
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
