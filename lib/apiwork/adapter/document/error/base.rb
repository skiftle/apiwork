# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Base < Document::Base
          def build_response(error)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
