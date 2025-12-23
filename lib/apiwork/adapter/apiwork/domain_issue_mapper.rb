# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class DomainIssueMapper
        def self.call(record, root_path: [])
          new(record, root_path).call
        end

        def initialize(record, root_path)
          @record = record
          @root_path = Array(root_path)
        end

        def call
          return [] unless @record.respond_to?(:errors)
          return [] unless @record.errors.any?

          attribute_issues + association_issues
        end

        private

        def attribute_issues
          @record.errors.filter_map do |error|
            next if nested_attribute_error?(error)

            build_issue(error)
          end
        end

        def association_issues
          has_many_issues + has_one_issues
        end

        def has_many_issues
          collect_association_issues(:has_many)
        end

        def has_one_issues
          collect_association_issues(:has_one)
        end

        def collect_association_issues(association_type)
          result = []

          @record.class.reflect_on_all_associations(association_type).each do |association|
            associated = @record.send(association.name)
            next unless associated

            items = association_type == :has_many ? associated : [associated]
            next unless items.respond_to?(:each)

            items.each_with_index do |item, index|
              next unless item.respond_to?(:errors)
              next unless item.errors.any?

              nested_path = build_association_path(association.name, index, association_type)
              result.concat(self.class.call(item, root_path: nested_path))
            end
          end

          result
        end

        def build_association_path(name, index, type)
          if type == :has_many
            @root_path + [name, index]
          else
            @root_path + [name]
          end
        end

        def nested_attribute_error?(error)
          error.attribute.to_s.include?('.')
        end

        def build_issue(error)
          code = CodeNormalizer.call(error, @record)
          attribute = resolve_attribute(error.attribute)
          path = @root_path + [attribute]

          Issue.new(
            layer: :domain,
            code:,
            detail: DetailResolver.detail_for(code),
            path:,
            meta: MetaBuilder.call(code, error)
          )
        end

        def resolve_attribute(attribute)
          return attribute if attribute == :base
          return attribute unless belongs_to_association?(attribute)

          :"#{attribute}_id"
        end

        def belongs_to_association?(attribute)
          belongs_to_names.include?(attribute)
        end

        def belongs_to_names
          @belongs_to_names ||= @record.class.reflect_on_all_associations(:belongs_to).map(&:name)
        end
      end
    end
  end
end
