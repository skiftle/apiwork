# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Response
        class Base
          attr_reader :api_class, :response

          class << self
            def phase(value = nil)
              @phase = value if value
              @phase || :after
            end

            def transform(response, api_class:)
              new(response, api_class:).transform
            end
          end

          def initialize(response, api_class:)
            @response = response
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
