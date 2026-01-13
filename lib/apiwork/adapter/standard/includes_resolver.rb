# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class IncludesResolver
        attr_reader :schema_class

        def initialize(schema_class)
          @schema_class = schema_class
        end

        def build(for_collection: true, params: {})
          return {} if schema_class.associations.empty?

          combined = {}

          combined.deep_merge!(always_included)

          if for_collection
            combined.deep_merge!(extract_from_filter(params[:filter]))
            combined.deep_merge!(extract_from_sort(params[:sort]))
          end

          apply_explicit_includes(combined, params[:include])

          combined
        end

        def always_included(visited = Set.new)
          return {} if visited.include?(schema_class.name)

          visited = visited.dup.add(schema_class.name)
          result = {}

          schema_class.associations.each do |name, definition|
            next unless definition.always_included?

            association = schema_class.model_class.reflect_on_association(name)

            nested_schema_class = resolve_schema_class(definition, association)
            next unless nested_schema_class

            if nested_schema_class.respond_to?(:new)
              builder = self.class.new(nested_schema_class)
              result[name] = builder.always_included(visited)
            else
              result[name] = {}
            end
          end

          result
        end

        private

        def extract_from_filter(filter_hash)
          return {} if filter_hash.blank?

          AssociationExtractor.new(schema_class).extract_from_filter(filter_hash)
        end

        def extract_from_sort(sort_hash)
          return {} if sort_hash.blank?

          AssociationExtractor.new(schema_class).extract_from_sort(sort_hash)
        end

        def apply_explicit_includes(combined, include_params)
          return if include_params.blank?

          include_params.each do |key, value|
            key = key.to_sym
            association = schema_class.associations[key]

            if false?(value)
              next if association&.always_included?

              combined.delete(key)

            elsif value.is_a?(Hash)
              normalized = normalize_nested_includes(value)
              combined[key] = if combined.key?(key) && combined[key].is_a?(Hash)
                                deep_merge_includes(combined[key], normalized)
                              else
                                normalized
                              end
            elsif true?(value)
              combined[key] ||= {}
            end
          end
        end

        def deep_merge_includes(base, override)
          self.class.deep_merge_includes(base, override)
        end

        def self.deep_merge_includes(base, override)
          result = base.dup
          override.each do |key, value|
            key = key.to_sym
            result[key] = if result[key].is_a?(Hash) && value.is_a?(Hash)
                            deep_merge_includes(result[key], value)
                          else
                            value
                          end
          end
          result
        end

        def normalize_nested_includes(hash)
          result = {}
          hash.each do |key, value|
            key = key.to_sym

            next if false?(value)

            result[key] = if true?(value)
                            {}
                          elsif value.is_a?(Hash)
                            normalize_nested_includes(value)
                          else
                            {}
                          end
          end
          result
        end

        def true?(value)
          [true, 'true'].include?(value)
        end

        def false?(value)
          [false, 'false'].include?(value)
        end

        def resolve_schema_class(definition, association)
          definition.schema_class || infer_association_schema(association)
        end

        def infer_association_schema(association)
          return nil if association.polymorphic?

          namespace = schema_class.name.deconstantize
          "#{namespace}::#{association.klass.name.demodulize}Schema".safe_constantize
        end
      end
    end
  end
end
