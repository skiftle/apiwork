# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Request
        class Base
          attr_reader :api_class, :request

          class << self
            def phase(value = nil)
              @phase = value if value
              @phase || :before
            end

            def transform(request, api_class:)
              new(request, api_class:).transform
            end
          end

          def initialize(request, api_class:)
            @request = request
            @api_class = api_class
          end

          def transform
            raise NotImplementedError
          end
        end
      end
    end
  end
end
