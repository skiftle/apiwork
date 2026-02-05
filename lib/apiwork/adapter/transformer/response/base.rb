# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Response
        # @api public
        # Base class for response transformers.
        #
        # Response transformers modify responses before they are returned.
        # Register transformers in capabilities using {Capability::Base.response_transformer}.
        #
        # @example Custom response transformer
        #   class MyTransformer < Transformer::Response::Base
        #     def transform
        #       response.transform(&method(:process))
        #     end
        #
        #     private
        #
        #     def process(body)
        #       # transform body
        #     end
        #   end
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

          # @api public
          # Transforms the response.
          #
          # @return [Apiwork::Response] the transformed response
          def transform
            raise NotImplementedError
          end
        end
      end
    end
  end
end
