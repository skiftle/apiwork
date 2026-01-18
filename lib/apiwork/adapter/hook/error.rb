# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Error
        def prepare(callable = nil, &block)
          @prepare = callable || block if callable || block
          @prepare
        end

        def render(callable = nil, &block)
          @render = callable || block if callable || block
          @render
        end

        def run_prepare(issues, layer, state)
          return issues unless @prepare

          call_hook(@prepare, issues, layer, state)
        end

        def run_render(issues, layer, state)
          return issues unless @render

          call_hook(@render, issues, layer, state)
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
