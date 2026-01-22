# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Base < Document::Base
          attr_reader :additions, :data, :meta, :schema_class

          def initialize(schema_class, data, additions, meta)
            super()
            @schema_class = schema_class
            @data = data
            @additions = additions
            @meta = meta
          end
        end
      end
    end
  end
end
