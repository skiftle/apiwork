# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Base < Document::Base
          attr_reader :additions, :capabilities, :data, :meta, :schema_class

          def initialize(schema_class, data, additions, capabilities, meta)
            super()
            @additions = additions
            @capabilities = capabilities
            @data = data
            @meta = meta
            @schema_class = schema_class
          end
        end
      end
    end
  end
end
