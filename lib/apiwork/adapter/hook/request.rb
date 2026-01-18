# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Request
        def before_validation(callable = nil, &block)
          @before_validation = callable || block if callable || block
          @before_validation
        end

        def after_validation(callable = nil, &block)
          @after_validation = callable || block if callable || block
          @after_validation
        end

        def run_before_validation(request)
          return request unless @before_validation

          call_hook(@before_validation, request)
        end

        def run_after_validation(request)
          return request unless @after_validation

          call_hook(@after_validation, request)
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
