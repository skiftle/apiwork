# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Response
        # @api public
        # Base class for response transformers.
        #
        # Response transformers modify responses before they are returned.
        # Register transformers in capabilities using {Adapter::Capability::Base.response_transformer}.
        #
        # @example Add generated_at to response
        #   class MyResponseTransformer < Transformer::Response::Base
        #     def transform
        #       response.transform_body { |body| body.merge(generated_at: Time.zone.now) }
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
          # @return [Response] the transformed response
          def transform
            raise NotImplementedError
          end
        end
      end
    end
  end
end
