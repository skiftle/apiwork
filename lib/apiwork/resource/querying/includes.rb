# frozen_string_literal: true

module Apiwork
  module Resource
    module Querying
      module Includes
        extend ActiveSupport::Concern

      class_methods do
        def apply_includes(scope)
          return scope if association_definitions.empty?

          includes_hash = @includes_hash ||= build_includes_hash
          return scope if includes_hash.empty?

          scope.includes(includes_hash)
        end

        def build_includes_hash(visited = Set.new)
          includes_hash = {}
          if visited.include?(name)
            error = Apiwork::ConfigurationError.new(
              code: :circular_dependency,
              detail: "Circular dependency detected in #{name}, skipping nested includes",
              path: [name]
            )
            Apiwork::Errors::Handler.handle(error, context: { resource: name })
            return {}
          end
          visited = visited.dup.add(name)

          association_definitions.each do |assoc_name, assoc_def|
            association = model_class.reflect_on_association(assoc_name)
            next if association&.polymorphic?

            resource_class = assoc_def.resource_class || Apiwork::Resource::Resolver.from_association(association, self)
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
  end
end
