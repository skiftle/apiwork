# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class ValidationAdapter
        def initialize(record, schema_class: nil, root_path: nil)
          @record = record
          @schema_class = schema_class

          @root_path = if root_path
                         Array(root_path)
                       elsif @schema_class
                         build_root_path(@schema_class)
                       else
                         [:data] # Default fallback
                       end
        end

        def convert
          return [] unless @record.respond_to?(:errors)

          errors = []
          errors.concat(convert_attribute_errors)
          errors.concat(convert_association_errors_of_type(:has_many))
          errors.concat(convert_association_errors_of_type(:has_one))
          errors
        end

        private

        def build_root_path(schema_class)
          type_key = schema_class.root_key.singular
          [type_key.to_sym]
        end

        def convert_attribute_errors
          return [] unless @record.errors.any?

          @record.errors.filter_map do |error|
            next if error.attribute.to_s.include?('.')

            attribute_name = if belongs_to?(error.attribute)
                               "#{error.attribute}_id".to_sym
                             else
                               error.attribute
                             end

            path = [@root_path, attribute_name].flatten

            issue(error, path: path)
          end
        end

        def convert_association_errors_of_type(association_type)
          errors = []

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

              converter = self.class.new(item, root_path: association_path)
              errors.concat(converter.convert)
            end
          end

          errors
        end

        def belongs_to?(attribute)
          @record.class.reflect_on_all_associations(:belongs_to)
                 .map(&:name)
                 .include?(attribute)
        end

        def issue(rails_error, path:)
          meta = { attribute: rails_error.attribute }

          if rails_error.options
            %i[in minimum maximum count is too_short too_long].each do |key|
              value = rails_error.options[key]
              meta[key] = value if value
            end
          end

          Issue.new(
            code: rails_error.type,
            detail: rails_error.message,
            path: path,
            meta: meta
          )
        end
      end
    end
  end
end
