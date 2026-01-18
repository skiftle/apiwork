# frozen_string_literal: true

module Apiwork
  module Adapter
    module Hook
      class Register
        def api(callable = nil, &block)
          @api = callable || block if callable || block
          @api
        end

        def contract(callable = nil, &block)
          @contract = callable || block if callable || block
          @contract
        end

        def run_api(registrar, capabilities)
          return unless @api

          call_hook(@api, registrar, capabilities)
        end

        def run_contract(registrar, schema_class, actions)
          return unless @contract

          call_hook(@contract, registrar, schema_class, actions)
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
