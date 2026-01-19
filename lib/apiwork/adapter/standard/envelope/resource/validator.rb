# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Resource < Adapter::Envelope::Resource
          class Validator
            def self.validate!(record, schema_class)
              new(record, schema_class).validate!
            end

            def initialize(record, schema_class)
              @record = record
              @schema_class = schema_class
            end

            def validate!
              return unless @record.respond_to?(:errors) && @record.errors.any?

              raise DomainError, issues
            end

            def issues
              IssueMapper.call(
                @record,
                locale_key: @schema_class.api_class.structure.locale_key,
                root_path: [@schema_class.root_key.singular.to_sym],
              )
            end
          end
        end
      end
    end
  end
end
