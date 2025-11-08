# frozen_string_literal: true

module Apiwork
  class IncludesBuilder
    attr_reader :schema

    def initialize(schema:)
      @schema = schema
    end

    # Build includes hash from all sources
    # For collections: serializable + filter + sort + explicit includes
    # For single resources: serializable + explicit includes only
    def build(params: {}, for_collection: true)
      return {} if schema.association_definitions.empty?

      combined = {}

      # 1. Start with serializable: true associations
      combined.deep_merge!(build_serializable_associations)

      # 2. Add associations from filter/sort (collections only)
      if for_collection
        combined.deep_merge!(extract_from_filter(params[:filter])) if params[:filter].present?
        combined.deep_merge!(extract_from_sort(params[:sort])) if params[:sort].present?
      end

      # 3. Apply explicit include params (can override with false)
      apply_explicit_includes(combined, params[:include]) if params[:include].present?

      combined
    end

    private

    # Build includes hash from serializable: true associations only
    def build_serializable_associations(visited = Set.new)
      return {} if visited.include?(schema.name)

      visited = visited.dup.add(schema.name)
      result = {}

      schema.association_definitions.each do |name, definition|
        next unless definition.serializable?

        association = schema.model_class.reflect_on_association(name)
        next if association&.polymorphic?

        nested_schema = resolve_schema_class(definition, association)
        next unless nested_schema

        if nested_schema.respond_to?(:new)
          builder = self.class.new(schema: nested_schema)
          nested = builder.send(:build_serializable_associations, visited)
          result[name] = nested.any? ? nested : {}
        else
          result[name] = {}
        end
      end

      result
    end

    # Extract associations from filter params
    def extract_from_filter(filter_hash)
      return {} if filter_hash.blank?

      AssociationExtractor.new(schema: schema).extract_from_filter(filter_hash)
    end

    # Extract associations from sort params
    def extract_from_sort(sort_hash)
      return {} if sort_hash.blank?

      AssociationExtractor.new(schema: schema).extract_from_sort(sort_hash)
    end

    # Apply explicit include params, respecting false to exclude
    def apply_explicit_includes(combined, include_params)
      include_params.each do |key, value|
        key_sym = key.to_sym

        if value == false || value == 'false'
          # Explicit false - remove from includes
          combined.delete(key_sym)
        elsif value.is_a?(Hash)
          # Nested include - process recursively to convert true → {}
          combined[key_sym] = normalize_nested_includes(value)
        elsif value == true || value == 'true'
          # Explicit true - ensure included
          combined[key_sym] ||= {}
        end
      end
    end

    # Normalize nested include params by converting true → {}
    # Rails .includes() expects { comments: { post: {} } }, not { comments: { post: true } }
    def normalize_nested_includes(hash)
      result = {}
      hash.each do |key, value|
        key_sym = key.to_sym
        if value == true || value == 'true'
          result[key_sym] = {}
        elsif value.is_a?(Hash)
          result[key_sym] = normalize_nested_includes(value)
        elsif value != false && value != 'false'
          # Unknown value type - default to empty hash
          result[key_sym] = {}
        end
        # Skip if value is false
      end
      result
    end

    # Resolve schema class from definition or association
    def resolve_schema_class(definition, association)
      schema_class = definition.schema_class || Apiwork::Schema::Resolver.from_association(association, schema)

      # Handle string class names
      if schema_class.is_a?(String)
        schema_class = begin
          schema_class.constantize
        rescue StandardError
          nil
        end
      end

      schema_class
    end

    # Helper class to extract associations from filter/sort params
    class AssociationExtractor
      attr_reader :schema

      def initialize(schema:)
        @schema = schema
      end

      def extract_from_filter(filter_hash, visited = Set.new)
        return {} if filter_hash.blank?
        return {} if visited.include?(schema.name)

        visited = visited.dup.add(schema.name)
        result = {}

        filter_hash.each do |key, value|
          key_sym = key.to_sym
          association_definition = schema.association_definitions[key_sym]

          next unless association_definition

          # Found association in filter - must include it
          result[key_sym] = {}

          # Check if there are nested associations to extract
          if value.is_a?(Hash)
            nested_schema = resolve_nested_schema(association_definition)

            if nested_schema&.respond_to?(:association_definitions)
              extractor = self.class.new(schema: nested_schema)
              nested_includes = extractor.extract_from_filter(value, visited)
              result[key_sym] = nested_includes if nested_includes.any?
            end
          end
        end

        result
      end

      def extract_from_sort(sort_hash, visited = Set.new)
        return {} if sort_hash.blank?
        return {} if visited.include?(schema.name)

        visited = visited.dup.add(schema.name)
        result = {}

        sort_array = sort_hash.is_a?(Array) ? sort_hash : [sort_hash]

        sort_array.each do |sort_item|
          next unless sort_item.is_a?(Hash)

          sort_item.each do |key, value|
            key_sym = key.to_sym
            association_definition = schema.association_definitions[key_sym]

            next unless association_definition

            # Found association in sort - must include it
            result[key_sym] = {}

            # Check if there are nested associations to extract
            if value.is_a?(Hash)
              nested_schema = resolve_nested_schema(association_definition)

              if nested_schema&.respond_to?(:association_definitions)
                extractor = self.class.new(schema: nested_schema)
                nested_includes = extractor.extract_from_sort(value, visited)
                result[key_sym] = nested_includes if nested_includes.any?
              end
            end
          end
        end

        result
      end

      private

      def resolve_nested_schema(association_definition)
        nested_schema = association_definition.schema_class

        # Handle string class names
        if nested_schema.is_a?(String)
          nested_schema = begin
            nested_schema.constantize
          rescue StandardError
            nil
          end
        end

        nested_schema
      end
    end
  end
end
