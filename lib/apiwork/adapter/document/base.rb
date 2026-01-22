# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Base
        class << self
          def response_types(klass)
            @response_types_class = klass
          end

          attr_reader :response_types_class
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
