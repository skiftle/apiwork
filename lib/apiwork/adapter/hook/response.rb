# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Response
        def initialize
          @record = Record.new
          @collection = Collection.new
          @error = Error.new
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

        def finalize(callable = nil, &block)
          @finalize = callable || block if callable || block
          @finalize
        end

        def run_finalize(response)
          return response unless @finalize

          call_hook(@finalize, response)
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
