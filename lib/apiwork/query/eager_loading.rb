# frozen_string_literal: true

module Apiwork
  class Query
    module EagerLoading
      def apply_includes(scope, includes_param = nil)
        return scope if schema.association_definitions.empty?

        includes_hash = if includes_param
                          build_includes_hash_from_param(includes_param)
                        else
                          @includes_hash ||= build_includes_hash
                        end

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

      def build_includes_hash(visited = Set.new)
        includes_hash = {}
        if visited.include?(schema.name)
          error = Apiwork::ConfigurationError.new(
            code: :circular_dependency,
            detail: "Circular dependency detected in #{schema.name}, skipping nested includes",
            path: [schema.name]
          )
          Apiwork::Errors::Handler.handle(error, context: { resource: schema.name })
          return {}
        end
        visited = visited.dup.add(schema.name)

        schema.association_definitions.each do |assoc_name, assoc_def|
          association = schema.model_class.reflect_on_association(assoc_name)
          next if association&.polymorphic?

          resource_class = assoc_def.schema_class || Apiwork::Schema::Resolver.from_association(association, schema)
          if resource_class.respond_to?(:build_includes_hash)
            nested_includes = resource_class.build_includes_hash(visited)
            includes_hash[assoc_name] = nested_includes.any? ? nested_includes : {}
          else
            includes_hash[assoc_name] = {}
          end
        end
        includes_hash
      end
    end
  end
end
