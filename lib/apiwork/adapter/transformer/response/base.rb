# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Response
        class Base
          attr_reader :response

          class << self
            def transform(response)
              new(response).transform
            end
          end

          def initialize(response)
            @response = response
          end

          def transform
            raise NotImplementedError
          end
        end
      end
    end
  end
end
