# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing
          class Result < Adapter::Capability::Result::Base
            def apply
              validate_record!(data, schema_class)
              result(data:)
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
end
