# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Response
        attr_reader :transforms

        def initialize
          @record = Record.new
          @collection = Collection.new
          @error = Error.new
          @transforms = []
        end

        def record(&block)
          @record.instance_eval(&block) if block
          @record
        end

        def collection(&block)
          @collection.instance_eval(&block) if block
          @collection
        end

        def error(&block)
          @error.instance_eval(&block) if block
          @error
        end

        def transform(callable = nil, &block)
          transformer = callable || block
          return unless transformer

          @transforms << transformer
        end

        def run_transforms(response, **context)
          @transforms.reduce(response) { |res, t| call_transformer(t, res, **context) }
        end

        def inherit_from(parent)
          @transforms = parent.transforms + @transforms
        end

        private

        def call_transformer(transformer, response, **context)
          callable = transformer.respond_to?(:call) ? transformer : transformer.new
          call_with_context(callable, response, **context)
        end

        def call_with_context(callable, response, **context)
          if accepts_keywords?(callable)
            callable.call(response, **context)
          else
            callable.call(response)
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
