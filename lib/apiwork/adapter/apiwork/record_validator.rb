# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class RecordValidator
        attr_reader :schema_class

        def self.validate(record, schema_class)
          new(record, schema_class).validate
        end

        def initialize(record, schema_class = nil)
          @record = record
          @schema_class = schema_class
        end

        def validate
          return unless @record.respond_to?(:errors) && @record.errors.any?

          raise ValidationError, issues
        end

        def issues
          DomainIssueMapper.call(@record, root_path: root_path)
        end

        private

        def root_path
          return [:data] unless @schema_class

          type_key = @schema_class.root_key.singular
          [type_key.to_sym]
        end
      end
    end
  end
end
