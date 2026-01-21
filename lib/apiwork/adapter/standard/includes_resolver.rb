# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class IncludesResolver
        attr_reader :schema_class

        def initialize(schema_class)
          @schema_class = schema_class
        end

        def always_included(visited = Set.new)
          return {} if visited.include?(schema_class.name)

          visited = visited.dup.add(schema_class.name)
          result = {}

          schema_class.associations.each do |name, association|
            next unless association.include == :always

            reflection = schema_class.model_class.reflect_on_association(name)

            nested_schema_class = resolve_schema_class(association, reflection)
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

        private

        def resolve_schema_class(association, reflection)
          association.schema_class || infer_association_schema(reflection)
        end

        def infer_association_schema(reflection)
          return nil if reflection.polymorphic?

          namespace = schema_class.name.deconstantize
          "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
        end
      end
    end
  end
end
