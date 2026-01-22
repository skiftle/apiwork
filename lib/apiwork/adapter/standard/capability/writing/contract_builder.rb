# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              TypeBuilder.build(registrar, schema_class)

              root_key = schema_class.root_key.singular.to_sym

              %i[create update].each do |action_name|
                next unless actions.key?(action_name)

                payload_type_name = :"#{action_name}_payload"
                next unless type?(payload_type_name)

                contract_action = action(action_name)
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
