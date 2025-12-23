# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class RecordValidator
        SAFE_META_KEYS = %i[minimum maximum count].freeze

        attr_reader :schema_class

        def self.validate(record, schema_class)
          new(record, schema_class).validate
        end

        def initialize(record, schema_class = nil, root_path: nil)
          @record = record
          @schema_class = schema_class

          @root_path = if root_path
                         Array(root_path)
                       elsif @schema_class
                         build_root_path(@schema_class)
                       else
                         [:data]
                       end
        end

        def validate
          return unless @record.respond_to?(:errors) && @record.errors.any?

          raise ValidationError, issues
        end

        def issues
          attribute_issues + association_issues(:has_many) + association_issues(:has_one)
        end

        private

        def build_root_path(schema_class)
          type_key = schema_class.root_key.singular
          [type_key.to_sym]
        end

        def attribute_issues
          return [] unless @record.errors.any?

          @record.errors.filter_map do |error|
            next if error.attribute.to_s.include?('.')

            attribute_name = if belongs_to?(error.attribute)
                               "#{error.attribute}_id".to_sym
                             else
                               error.attribute
                             end

            path = [@root_path, attribute_name].flatten

            issue(error, path)
          end
        end

        def association_issues(association_type)
          result = []

          @record.class.reflect_on_all_associations(association_type).each do |association|
            associated = @record.send(association.name)

            items = if association_type == :has_many
                      next unless associated.respond_to?(:each)
                      next unless associated.any?

                      associated
                    else
                      next unless associated

                      [associated]
                    end

            items.each_with_index do |item, index|
              next unless item.respond_to?(:errors)
              next unless item.errors.any?

              association_path = if association_type == :has_many
                                   [@root_path, association.name, index].flatten
                                 else
                                   [@root_path, association.name].flatten
                                 end

              validator = self.class.new(item, root_path: association_path)
              result.concat(validator.issues)
            end
          end

          result
        end

        def belongs_to?(attribute)
          belongs_to_names.include?(attribute)
        end

        def belongs_to_names
          @belongs_to_names ||= @record.class.reflect_on_all_associations(:belongs_to).map(&:name)
        end

        def issue(error, path)
          Issue.new(
            layer: :domain,
            code: error.type,
            detail: error.message,
            path:,
            meta: safe_meta(error)
          )
        end

        def safe_meta(error)
          meta = { field: error.attribute }

          return meta unless error.options

          SAFE_META_KEYS.each do |key|
            value = error.options[key]
            meta[key] = value if value
          end

          meta
        end
      end
    end
  end
end
