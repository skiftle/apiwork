# frozen_string_literal: true

module Apiwork
  class IncludesBuilder
    include Concerns::SafeConstantize

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
    # For serializable associations, merge nested includes rather than replace
    def apply_explicit_includes(combined, include_params)
      include_params.each do |key, value|
        key_sym = key.to_sym

        if explicitly_false?(value)
          combined.delete(key_sym)
        elsif value.is_a?(Hash)
          # Nested include - deep merge with existing (for serializable associations)
          normalized = normalize_nested_includes(value)
          combined[key_sym] = if combined.key?(key_sym) && combined[key_sym].is_a?(Hash)
                                # Association already exists (likely serializable) - deep merge nested includes
                                deep_merge_includes(combined[key_sym], normalized)
                              else
                                # New association - set directly
                                normalized
                              end
        elsif explicitly_true?(value)
          combined[key_sym] ||= {}
        end
      end
    end

    # Deep merge two include hashes
    # Recursively merges nested hashes, preserving both automatic and explicit includes
    def deep_merge_includes(base, override)
      self.class.deep_merge_includes(base, override)
    end

    def self.deep_merge_includes(base, override)
      result = base.dup
      override.each do |key, value|
        key_sym = key.to_sym
        result[key_sym] = if result[key_sym].is_a?(Hash) && value.is_a?(Hash)
                            deep_merge_includes(result[key_sym], value)
                          else
                            value
                          end
      end
      result
    end

    # Normalize nested include params by converting true → {}
    # Rails .includes() expects { comments: { post: {} } }, not { comments: { post: true } }
    def normalize_nested_includes(hash)
      result = {}
      hash.each do |key, value|
        key_sym = key.to_sym

        next if explicitly_false?(value)

        result[key_sym] = if explicitly_true?(value)
                            {}
                          elsif value.is_a?(Hash)
                            normalize_nested_includes(value)
                          else
                            # Unknown value type - default to empty hash
                            {}
                          end
      end
      result
    end

    def explicitly_true?(value)
      [true, 'true'].include?(value)
    end

    def explicitly_false?(value)
      [false, 'false'].include?(value)
    end

    # Resolve schema class from definition or association
    def resolve_schema_class(definition, association)
      schema_class = definition.schema_class || Apiwork::Schema::Resolver.from_association(association, schema)

      # Handle string class names
      schema_class = constantize_safe(schema_class) if schema_class.is_a?(String)

      schema_class
    end

    # Helper class to extract associations from filter/sort params
    class AssociationExtractor
      include Concerns::SafeConstantize

      attr_reader :schema

      def initialize(schema:)
        @schema = schema
      end

      def extract_from_filter(filter_hash, visited = Set.new)
        return {} if filter_hash.blank?
        return {} if visited.include?(schema.name)

        visited = visited.dup.add(schema.name)
        result = {}

        # Handle array format (OR logic)
        if filter_hash.is_a?(Array)
          filter_hash.each do |filter_item|
            extracted = extract_from_filter(filter_item, visited)
            result = IncludesBuilder.deep_merge_includes(result, extracted)
          end
          return result
        end

        filter_hash.each do |key, value|
          key_sym = key.to_sym

          # Handle logical operators - recursively extract from their values
          if %i[_or _and].include?(key_sym) && value.is_a?(Array)
            value.each do |filter_item|
              extracted = extract_from_filter(filter_item, visited)
              result = IncludesBuilder.deep_merge_includes(result, extracted)
            end
            next
          elsif key_sym == :_not && value.is_a?(Hash)
            extracted = extract_from_filter(value, visited)
            result = IncludesBuilder.deep_merge_includes(result, extracted)
            next
          end

          association_definition = schema.association_definitions[key_sym]

          next unless association_definition

          # Found association in filter - must include it
          result[key_sym] = {}

          # Check if there are nested associations to extract
          next unless value.is_a?(Hash)

          nested_schema = resolve_nested_schema(association_definition)

          next unless nested_schema.respond_to?(:association_definitions)

          extractor = self.class.new(schema: nested_schema)
          nested_includes = extractor.extract_from_filter(value, visited)
          result[key_sym] = nested_includes if nested_includes.any?
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
            next unless value.is_a?(Hash)

            nested_schema = resolve_nested_schema(association_definition)

            next unless nested_schema.respond_to?(:association_definitions)

            extractor = self.class.new(schema: nested_schema)
            nested_includes = extractor.extract_from_sort(value, visited)
            result[key_sym] = nested_includes if nested_includes.any?
          end
        end

        result
      end

      private

      def resolve_nested_schema(association_definition)
        nested_schema = association_definition.schema_class

        # Handle string class names
        nested_schema = constantize_safe(nested_schema) if nested_schema.is_a?(String)

        nested_schema
      end
    end
  end
end
