# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Record
        def prepare(callable = nil, &block)
          @prepare = callable || block if callable || block
          @prepare
        end

        def render(callable = nil, &block)
          @render = callable || block if callable || block
          @render
        end

        def run_prepare(record, schema_class, state)
          return record unless @prepare

          call_hook(@prepare, record, schema_class, state)
        end

        def run_render(data, schema_class, state)
          return data unless @render

          call_hook(@render, data, schema_class, state)
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
