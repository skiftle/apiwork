# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing < Adapter::Capability::Base
          capability_name :writing
          applies_to :create, :update
          input :record

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

          def apply(data, _params, context)
            record = data[:data]
            validate_record!(record, context.schema_class)
            data
          end

          private

          def validate_record!(record, schema_class)
            return unless record.respond_to?(:errors) && record.errors.any?

            issues = IssueMapper.call(
              record,
              locale_key: schema_class.api_class.structure.locale_key,
              root_path: [schema_class.root_key.singular.to_sym],
            )
            raise DomainError, issues
          end
        end
      end
    end
  end
end
