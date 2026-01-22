# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Base < Document::Base
          def build_response(collection, additions, meta)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
