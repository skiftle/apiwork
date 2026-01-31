# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Request
        class Base
          attr_reader :request

          class << self
            def phase(value = nil)
              @phase = value if value
              @phase || :before
            end

            def transform(request)
              new(request).transform
            end
          end

          def initialize(request)
            @request = request
          end

          def transform
            raise NotImplementedError
          end
        end
      end
    end
  end
end
