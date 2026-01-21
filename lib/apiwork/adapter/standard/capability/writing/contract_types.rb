# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing
          class ContractTypes < Adapter::Capability::ContractTypes::Base
            def register(context)
              TypeBuilder.build(context.registrar, context.schema_class)

              root_key = context.schema_class.root_key.singular.to_sym

              %i[create update].each do |action_name|
                next unless context.actions.key?(action_name)

                payload_type_name = :"#{action_name}_payload"
                next unless context.registrar.type?(payload_type_name)

                contract_action = context.registrar.action(action_name)
                next if contract_action.resets_request?

                contract_action.request do
                  body do
                    reference root_key, to: payload_type_name
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
