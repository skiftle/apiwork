# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Base < Document::Base
          document_type :collection
        end
      end
    end
  end
end
