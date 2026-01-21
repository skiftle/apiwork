# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class ContractTypes < Adapter::Capability::ContractTypes::Base
            def register(context)
              TypeBuilder.build(context.registrar, context.schema_class)

              return unless context.registrar.type?(:include)

              context.actions.each_key do |action_name|
                context.registrar.action(action_name) do
                  request do
                    query do
                      reference? :include
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
