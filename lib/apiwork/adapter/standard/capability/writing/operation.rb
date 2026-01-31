# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing
          class Operation < Adapter::Capability::Operation::Base
            scope :member

            def apply
              validate_record!(data, representation_class)
            end

            private

            def validate_record!(record, representation_class)
              return unless record.respond_to?(:errors) && record.errors.any?

              issues = IssueMapper.map(
                record,
                locale_key: representation_class.api_class.structure.locale_key,
                root_path: [representation_class.root_key.singular.to_sym],
              )
              raise DomainError, issues
            end
          end
        end
      end
    end
  end
end
