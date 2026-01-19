# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Writing < Adapter::Feature
          feature_name :writing
          applies_to :create, :update

          request_transformer OpFieldTransformer, post: true

          def contract(registrar, schema_class, actions)
            TypeBuilder.build(registrar, schema_class)

            root_key = schema_class.root_key.singular.to_sym

            %i[create update].each do |action_name|
              next unless actions.key?(action_name)

              payload_type_name = :"#{action_name}_payload"
              next unless registrar.type?(payload_type_name)

              contract_action = registrar.action(action_name)
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
