# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Collection
        def prepare(callable = nil, &block)
          @prepare = callable || block if callable || block
          @prepare
        end

        def render(callable = nil, &block)
          @render = callable || block if callable || block
          @render
        end

        def run_prepare(collection, schema_class, state)
          return collection unless @prepare

          call_hook(@prepare, collection, schema_class, state)
        end

        def run_render(result, schema_class, state)
          return result unless @render

          call_hook(@render, result, schema_class, state)
        end

        private

        def call_hook(hook, *args)
          if hook.respond_to?(:call)
            hook.call(*args)
          else
            hook.new.call(*args)
          end
        end
      end
    end
  end
end
