# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Base < Document::Base
          attr_reader :error

          def initialize(error)
            super()
            @error = error
          end
        end
      end
    end
  end
end
