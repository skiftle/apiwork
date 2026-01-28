# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Base < Document::Base
          document_type :error

          def build
            json
          end
        end
      end
    end
  end
end
