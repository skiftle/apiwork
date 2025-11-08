# frozen_string_literal: true

module Apiwork
  class Query
    module AssociationExtractor
      # Extract association names from filter hash
      # filter: { comments: { author: "Alice" } } → { comments: {} }
      # filter: { comments: { user: { name: "Bob" } } } → { comments: { user: {} } }
      def extract_associations_from_filter(filter_hash, current_schema, visited = Set.new)
        return {} if filter_hash.blank?
        return {} if visited.include?(current_schema.name)

        visited = visited.dup.add(current_schema.name)
        result = {}

        filter_hash.each do |key, value|
          key_sym = key.to_sym
          association_definition = current_schema.association_definitions[key_sym]

          next unless association_definition

          # Found association in filter - must include it
          result[key_sym] = {}

          # Check if there are nested associations to extract
          if value.is_a?(Hash)
            nested_schema = association_definition.schema_class

            # Handle string class names
            if nested_schema.is_a?(String)
              nested_schema = begin
                nested_schema.constantize
              rescue StandardError
                nil
              end
            end

            # Recurse to find nested associations
            if nested_schema&.respond_to?(:association_definitions)
              nested_includes = extract_associations_from_filter(
                value,
                nested_schema,
                visited
              )
              result[key_sym] = nested_includes if nested_includes.any?
            end
          end
        end

        result
      end

      # Extract association names from sort hash
      # sort: { comments: { created_at: "desc" } } → { comments: {} }
      def extract_associations_from_sort(sort_hash, current_schema, visited = Set.new)
        return {} if sort_hash.blank?
        return {} if visited.include?(current_schema.name)

        visited = visited.dup.add(current_schema.name)
        result = {}

        sort_array = sort_hash.is_a?(Array) ? sort_hash : [sort_hash]

        sort_array.each do |sort_item|
          next unless sort_item.is_a?(Hash)

          sort_item.each do |key, value|
            key_sym = key.to_sym
            association_definition = current_schema.association_definitions[key_sym]

            next unless association_definition

            # Found association in sort - must include it
            result[key_sym] = {}

            # Check if there are nested associations to extract
            if value.is_a?(Hash)
              nested_schema = association_definition.schema_class

              # Handle string class names
              if nested_schema.is_a?(String)
                nested_schema = begin
                  nested_schema.constantize
                rescue StandardError
                  nil
                end
              end

              # Recurse to find nested associations
              if nested_schema&.respond_to?(:association_definitions)
                nested_includes = extract_associations_from_sort(
                  value,
                  nested_schema,
                  visited
                )
                result[key_sym] = nested_includes if nested_includes.any?
              end
            end
          end
        end

        result
      end
    end
  end
end
