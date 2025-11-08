# frozen_string_literal: true

module Apiwork
  class Query
    module EagerLoading
      def apply_includes(scope, params = {})
        return scope if schema.association_definitions.empty?

        includes_hash = build_combined_includes(params)
        return scope if includes_hash.empty?

        scope.includes(includes_hash)
      end

      def build_includes_hash_from_param(includes_param)
        return {} unless includes_param.is_a?(Hash)

        includes_hash = {}
        includes_param.each do |key, value|
          key = key.to_sym
          assoc_def = schema.association_definitions[key]
          next unless assoc_def

          if value.is_a?(TrueClass)
            includes_hash[key] = {}
          elsif value.is_a?(Hash)
            assoc_resource = assoc_def.schema_class
            if assoc_resource.is_a?(String)
              assoc_resource = begin
                assoc_resource.constantize
              rescue StandardError
                nil
              end
            end

            if assoc_resource&.respond_to?(:build_includes_hash_from_param)
              nested_hash = assoc_resource.build_includes_hash_from_param(value)
              includes_hash[key] = nested_hash.any? ? nested_hash : {}
            else
              includes_hash[key] = {}
            end
          end
        end

        includes_hash
      end

      # Build includes hash from serializable: true associations only
      def build_serializable_includes(visited = Set.new)
        return {} if visited.include?(schema.name)

        visited = visited.dup.add(schema.name)
        result = {}

        schema.association_definitions.each do |name, definition|
          next unless definition.serializable?

          association = schema.model_class.reflect_on_association(name)
          next if association&.polymorphic?

          nested_schema = definition.schema_class || Apiwork::Schema::Resolver.from_association(association, schema)

          # Handle string class names
          if nested_schema.is_a?(String)
            nested_schema = begin
              nested_schema.constantize
            rescue StandardError
              nil
            end
          end

          if nested_schema&.respond_to?(:build_serializable_includes)
            nested = nested_schema.build_serializable_includes(visited)
            result[name] = nested.any? ? nested : {}
          else
            result[name] = {}
          end
        end

        result
      end

      # Merge all include sources with explicit params having highest priority
      def build_combined_includes(params)
        combined = {}

        # 1. Start with serializable: true associations
        combined.deep_merge!(build_serializable_includes)

        # 2. Add associations from filter params
        if params[:filter].present?
          filter_includes = extract_associations_from_filter(params[:filter], schema)
          combined.deep_merge!(filter_includes)
        end

        # 3. Add associations from sort params
        if params[:sort].present?
          sort_includes = extract_associations_from_sort(params[:sort], schema)
          combined.deep_merge!(sort_includes)
        end

        # 4. Apply explicit include params (can override with false)
        if params[:include].present?
          apply_explicit_includes(combined, params[:include])
        end

        combined
      end

      # Apply explicit include params, respecting false to exclude
      def apply_explicit_includes(combined, include_params)
        include_params.each do |key, value|
          key_sym = key.to_sym

          if value == false || value == 'false'
            # Explicit false - remove from includes
            combined.delete(key_sym)
          elsif value.is_a?(Hash)
            # Nested include - merge deeply
            combined[key_sym] = value.deep_symbolize_keys
          elsif value == true || value == 'true'
            # Explicit true - ensure included
            combined[key_sym] ||= {}
          end
        end
      end
    end
  end
end
