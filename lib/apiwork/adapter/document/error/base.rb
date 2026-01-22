# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Base < Document::Base
          attr_reader :data

          def initialize(data)
            super()
            @data = data
          end
        end
      end
    end
  end
end
