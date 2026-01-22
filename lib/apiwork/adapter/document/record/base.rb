# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Base < Document::Base
          def build_response(record, additions, meta)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
