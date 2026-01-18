# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Response
        attr_reader :finalize_transforms

        def initialize
          @prepare_hooks = { collection: nil, error: nil, record: nil }
          @render_hooks = { collection: nil, error: nil, record: nil }
          @finalize_transforms = []
          @current_stage = nil
        end

        def prepare(&block)
          @current_stage = :prepare
          instance_eval(&block)
          @current_stage = nil
        end

        def render(&block)
          @current_stage = :render
          instance_eval(&block)
          @current_stage = nil
        end

        def finalize(&block)
          @current_stage = :finalize
          instance_eval(&block)
          @current_stage = nil
        end

        def record(callable = nil, &block)
          hook = callable || block
          case @current_stage
          when :prepare
            @prepare_hooks[:record] = hook
          when :render
            @render_hooks[:record] = hook
          end
        end

        def collection(callable = nil, &block)
          hook = callable || block
          case @current_stage
          when :prepare
            @prepare_hooks[:collection] = hook
          when :render
            @render_hooks[:collection] = hook
          end
        end

        def error(callable = nil, &block)
          hook = callable || block
          case @current_stage
          when :prepare
            @prepare_hooks[:error] = hook
          when :render
            @render_hooks[:error] = hook
          end
        end

        def transform(callable = nil, &block)
          return unless @current_stage == :finalize

          @finalize_transforms << (callable || block)
        end

        def run_prepare_record(record, schema_class, state)
          return record unless @prepare_hooks[:record]

          call_hook(@prepare_hooks[:record], record, schema_class, state)
        end

        def run_prepare_collection(collection, schema_class, state)
          return collection unless @prepare_hooks[:collection]

          call_hook(@prepare_hooks[:collection], collection, schema_class, state)
        end

        def run_prepare_error(issues, layer, state)
          return issues unless @prepare_hooks[:error]

          call_hook(@prepare_hooks[:error], issues, layer, state)
        end

        def run_render_record(data, schema_class, state)
          return data unless @render_hooks[:record]

          call_hook(@render_hooks[:record], data, schema_class, state)
        end

        def run_render_collection(result, schema_class, state)
          return result unless @render_hooks[:collection]

          call_hook(@render_hooks[:collection], result, schema_class, state)
        end

        def run_render_error(issues, layer, state)
          return issues unless @render_hooks[:error]

          call_hook(@render_hooks[:error], issues, layer, state)
        end

        def run_finalize(response, **context)
          @finalize_transforms.reduce(response) { |res, t| call_transformer(t, res, **context) }
        end

        def inherit_from(parent)
          @finalize_transforms = parent.finalize_transforms + @finalize_transforms
        end

        private

        def call_hook(hook, *args)
          if hook.respond_to?(:call)
            hook.call(*args)
          else
            hook.new.call(*args)
          end
        end

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
