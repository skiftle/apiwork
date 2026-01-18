# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Request
        attr_reader :post_transforms, :transforms

        def initialize
          @transforms = []
          @post_transforms = []
        end

        def transform(callable = nil, stage: nil, &block)
          transformer = callable || block
          return unless transformer

          if stage == :post
            @post_transforms << transformer
          else
            @transforms << transformer
          end
        end

        def run_transforms(request, **context)
          @transforms.reduce(request) { |req, t| call_transformer(t, req, **context) }
        end

        def run_post_transforms(request, **context)
          @post_transforms.reduce(request) { |req, t| call_transformer(t, req, **context) }
        end

        def inherit_from(parent)
          @transforms = parent.transforms + @transforms
          @post_transforms = parent.post_transforms + @post_transforms
        end

        private

        def call_transformer(transformer, request, **context)
          callable = transformer.respond_to?(:call) ? transformer : transformer.new
          call_with_context(callable, request, **context)
        end

        def call_with_context(callable, request, **context)
          if accepts_keywords?(callable)
            callable.call(request, **context)
          else
            callable.call(request)
          end
        end

        def accepts_keywords?(callable)
          method = callable.is_a?(Proc) ? callable : callable.method(:call)
          method.parameters.any? { |type, _| [:key, :keyreq, :keyrest].include?(type) }
        end
      end
    end
  end
end
