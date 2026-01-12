# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class IncludesResolver
        class AssociationExtractor
          attr_reader :schema_class

          def initialize(schema_class)
            @schema_class = schema_class
          end

          def extract_from_filter(filter_hash, visited = Set.new)
            return {} if filter_hash.blank?
            return {} if visited.include?(schema_class.name)

            visited = visited.dup.add(schema_class.name)
            result = {}

            if filter_hash.is_a?(Array)
              filter_hash.each do |filter_item|
                extracted = extract_from_filter(filter_item, visited)
                result = IncludesResolver.deep_merge_includes(result, extracted)
              end
              return result
            end

            filter_hash.each do |key, value|
              key = key.to_sym

              if %i[_or _and].include?(key) && value.is_a?(Array)
                value.each do |filter_item|
                  extracted = extract_from_filter(filter_item, visited)
                  result = IncludesResolver.deep_merge_includes(result, extracted)
                end
                next
              elsif key == :_not && value.is_a?(Hash)
                extracted = extract_from_filter(value, visited)
                result = IncludesResolver.deep_merge_includes(result, extracted)
                next
              end

              association_definition = schema_class.associations[key]

              next unless association_definition

              result[key] = {}

              next unless value.is_a?(Hash)

              nested_schema_class = association_definition.schema_class

              next unless nested_schema_class.respond_to?(:associations)

              extractor = self.class.new(nested_schema_class)
              nested_includes = extractor.extract_from_filter(value, visited)
              result[key] = nested_includes if nested_includes.any?
            end

            result
          end

          def extract_from_sort(sort_hash, visited = Set.new)
            return {} if sort_hash.blank?
            return {} if visited.include?(schema_class.name)

            visited = visited.dup.add(schema_class.name)
            result = {}

            sort_array = sort_hash.is_a?(Array) ? sort_hash : [sort_hash]

            sort_array.each do |sort_item|
              next unless sort_item.is_a?(Hash)

              sort_item.each do |key, value|
                key = key.to_sym
                association_definition = schema_class.associations[key]

                next unless association_definition

                result[key] = {}

                next unless value.is_a?(Hash)

                nested_schema_class = association_definition.schema_class

                next unless nested_schema_class.respond_to?(:associations)

                extractor = self.class.new(nested_schema_class)
                nested_includes = extractor.extract_from_sort(value, visited)
                result[key] = nested_includes if nested_includes.any?
              end
            end

            result
          end
        end
      end
    end
  end
end
