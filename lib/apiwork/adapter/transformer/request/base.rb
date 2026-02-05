# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Request
        # @api public
        # Base class for request transformers.
        #
        # Request transformers modify requests before or after validation.
        # Register transformers in capabilities using {Capability::Base.request_transformer}.
        #
        # @example Custom request transformer
        #   class MyTransformer < Transformer::Request::Base
        #     phase :before
        #
        #     def transform
        #       request.transform(&method(:process))
        #     end
        #
        #     private
        #
        #     def process(data)
        #       # transform data
        #     end
        #   end
        class Base
          attr_reader :request

          class << self
            # @api public
            # Sets or gets the transformer phase.
            #
            # @param value [Symbol, nil] :before (pre-validation) or :after (post-validation)
            # @return [Symbol] the phase (defaults to :before)
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

          # @api public
          # Transforms the request.
          #
          # @return [Apiwork::Request] the transformed request
          def transform
            raise NotImplementedError
          end
        end
      end
    end
  end
end
