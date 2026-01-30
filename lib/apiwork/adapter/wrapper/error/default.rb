# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Error
        class Default < Base
          shape do |shape|
            shape.extends(shape.data_type)
          end

          def json
            data
          end
        end
      end
    end
  end
end
