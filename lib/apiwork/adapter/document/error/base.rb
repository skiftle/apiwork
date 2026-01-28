# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Base < Document::Base
          document_type :error
        end
      end
    end
  end
end
