# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Transformer
        module Request
          # @api public
          # Base class for request transformers.
          #
          # Request transformers modify requests before or after validation.
          # Register transformers in capabilities using {Capability::Base.request_transformer}.
          #
          # @example Strip whitespace from strings
          #   class MyRequestTransformer < Capability::Transformer::Request::Base
          #     phase :before
          #
          #     def transform
          #       request.transform { |data| strip_strings(data) }
          #     end
          #
          #     private
          #
          #     def strip_strings(value)
          #       case value
          #       when String then value.strip
          #       when Hash then value.transform_values { |v| strip_strings(v) }
          #       when Array then value.map { |v| strip_strings(v) }
          #       else value
          #       end
          #     end
          #   end
          #
          # @see Standard::Capability::Filtering::RequestTransformer
          # @see Standard::Capability::Writing::RequestTransformer
          class Base
            attr_reader :request

            class << self
              # @api public
              # The phase for this transformer.
              #
              # @param value [Symbol, nil] (nil) [:after, :before]
              #   The phase. Defaults to `:before` when not set.
              # @return [Symbol]
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
            # @return [Request]
            def transform
              raise NotImplementedError
            end
          end
        end
      end
    end
  end
end
