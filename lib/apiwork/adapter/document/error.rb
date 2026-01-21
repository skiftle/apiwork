# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Error < Base
        def build_response(error)
          error
        end
      end
    end
  end
end
