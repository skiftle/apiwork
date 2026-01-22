# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Default < Base
          def build
            error
          end
        end
      end
    end
  end
end
