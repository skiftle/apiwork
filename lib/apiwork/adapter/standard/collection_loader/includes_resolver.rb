# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionLoader
        class IncludesResolver
          attr_reader :schema

          def initialize(schema:)
            @schema = schema
          end

          def build(params: {}, for_collection: true)
            return {} if schema.association_definitions.empty?

            combined = {}

            combined.deep_merge!(always_included)

            if for_collection
              combined.deep_merge!(extract_from_filter(params[:filter]))
              combined.deep_merge!(extract_from_sort(params[:sort]))
            end

            apply_explicit_includes(combined, params[:include])

            combined
          end

          private

          def always_included(visited = Set.new)
            return {} if visited.include?(schema.name)

            visited = visited.dup.add(schema.name)
            result = {}

            schema.association_definitions.each do |name, definition|
              next unless definition.always_included?

              association = schema.model_class.reflect_on_association(name)

              nested_schema = resolve_schema_class(definition, association)
              next unless nested_schema

              if nested_schema.respond_to?(:new)
                builder = self.class.new(schema: nested_schema)
                nested = builder.send(:always_included, visited)
                result[name] = nested.any? ? nested : {}
              else
                result[name] = {}
              end
            end

            result
          end

          def extract_from_filter(filter_hash)
            return {} if filter_hash.blank?

            AssociationExtractor.new(schema: schema).extract_from_filter(filter_hash)
          end

          def extract_from_sort(sort_hash)
            return {} if sort_hash.blank?

            AssociationExtractor.new(schema: schema).extract_from_sort(sort_hash)
          end

          def apply_explicit_includes(combined, include_params)
            return if include_params.blank?

            include_params.each do |key, value|
              key_name_sym = key.to_sym
              association_definition = schema.association_definitions[key_name_sym]

              if false?(value)
                next if association_definition&.always_included?

                combined.delete(key_name_sym)

              elsif value.is_a?(Hash)
                normalized = normalize_nested_includes(value)
                combined[key_name_sym] = if combined.key?(key_name_sym) && combined[key_name_sym].is_a?(Hash)
                                           deep_merge_includes(combined[key_name_sym], normalized)
                                         else
                                           normalized
                                         end
              elsif true?(value)
                combined[key_name_sym] ||= {}
              end
            end
          end

          def deep_merge_includes(base, override)
            self.class.deep_merge_includes(base, override)
          end

          def self.deep_merge_includes(base, override)
            result = base.dup
            override.each do |key, value|
              key_name_sym = key.to_sym
              result[key_name_sym] = if result[key_name_sym].is_a?(Hash) && value.is_a?(Hash)
                                       deep_merge_includes(result[key_name_sym], value)
                                     else
                                       value
                                     end
            end
            result
          end

          def normalize_nested_includes(hash)
            result = {}
            hash.each do |key, value|
              key_name_sym = key.to_sym

              next if false?(value)

              result[key_name_sym] = if true?(value)
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
            schema_class = definition.schema_class || Apiwork::Schema::Resolver.from_association(association, schema)

            schema_class = constantize_safe(schema_class) if schema_class.is_a?(String)

            schema_class
          end

          def constantize_safe(class_name)
            self.class.constantize_safe(class_name)
          end

          def self.constantize_safe(class_name)
            class_name.constantize
          rescue NameError
            nil
          end

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

              if filter_hash.is_a?(Array)
                filter_hash.each do |filter_item|
                  extracted = extract_from_filter(filter_item, visited)
                  result = IncludesResolver.deep_merge_includes(result, extracted)
                end
                return result
              end

              filter_hash.each do |key, value|
                key_name_sym = key.to_sym

                if %i[_or _and].include?(key_name_sym) && value.is_a?(Array)
                  value.each do |filter_item|
                    extracted = extract_from_filter(filter_item, visited)
                    result = IncludesResolver.deep_merge_includes(result, extracted)
                  end
                  next
                elsif key_name_sym == :_not && value.is_a?(Hash)
                  extracted = extract_from_filter(value, visited)
                  result = IncludesResolver.deep_merge_includes(result, extracted)
                  next
                end

                association_definition = schema.association_definitions[key_name_sym]

                next unless association_definition

                result[key_name_sym] = {}

                next unless value.is_a?(Hash)

                nested_schema = resolve_nested_schema(association_definition)

                next unless nested_schema.respond_to?(:association_definitions)

                extractor = self.class.new(schema: nested_schema)
                nested_includes = extractor.extract_from_filter(value, visited)
                result[key_name_sym] = nested_includes if nested_includes.any?
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
                  key_name_sym = key.to_sym
                  association_definition = schema.association_definitions[key_name_sym]

                  next unless association_definition

                  result[key_name_sym] = {}

                  next unless value.is_a?(Hash)

                  nested_schema = resolve_nested_schema(association_definition)

                  next unless nested_schema.respond_to?(:association_definitions)

                  extractor = self.class.new(schema: nested_schema)
                  nested_includes = extractor.extract_from_sort(value, visited)
                  result[key_name_sym] = nested_includes if nested_includes.any?
                end
              end

              result
            end

            private

            def resolve_nested_schema(association_definition)
              nested_schema = association_definition.schema_class

              nested_schema = IncludesResolver.constantize_safe(nested_schema) if nested_schema.is_a?(String)

              nested_schema
            end
          end
        end
      end
    end
  end
end
