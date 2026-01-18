# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Request
        attr_reader :after_transforms, :before_transforms

        def initialize
          @before_transforms = []
          @after_transforms = []
          @current_stage = nil
        end

        def before_validation(&block)
          @current_stage = :before
          instance_eval(&block)
          @current_stage = nil
        end

        def after_validation(&block)
          @current_stage = :after
          instance_eval(&block)
          @current_stage = nil
        end

        def transform(callable = nil, &block)
          transformer = callable || block
          return unless transformer

          case @current_stage
          when :before
            @before_transforms << transformer
          when :after
            @after_transforms << transformer
          end
        end

        def run_before_transforms(request, **context)
          @before_transforms.reduce(request) { |req, t| call_transformer(t, req, **context) }
        end

        def run_after_transforms(request, **context)
          @after_transforms.reduce(request) { |req, t| call_transformer(t, req, **context) }
        end

        def inherit_from(parent)
          @before_transforms = parent.before_transforms + @before_transforms
          @after_transforms = parent.after_transforms + @after_transforms
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
