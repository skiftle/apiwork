# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting < Adapter::Capability::Base
          class TypeBuilder
            MAX_RECURSION_DEPTH = 3

            attr_reader :registrar,
                        :schema_class

            def self.build(registrar, schema_class)
              new(registrar, schema_class).build
            end

            def initialize(registrar, schema_class)
              @registrar = registrar
              @schema_class = schema_class
            end

            def build
              build_sort_type(depth: 0, visited: Set.new)
            end

            def build_sort_type(depth: 0, visited: Set.new)
              return nil if visited.include?(schema_class)
              return nil if depth >= MAX_RECURSION_DEPTH

              visited = visited.dup.add(schema_class)

              return nil unless has_sortable_content?(visited)

              type_name = type_name(:sort, depth)

              existing_type = registrar.type?(type_name)
              return type_name if existing_type

              builder = self
              registrar_local = registrar

              type_options = { schema_class: schema_class }
              type_options = {} unless depth.zero?

              registrar.object(type_name, **type_options) do
                builder.schema_class.attributes.each do |name, attribute|
                  next unless attribute.sortable?

                  reference name, optional: true, to: :sort_direction
                end

                builder.schema_class.associations.each do |name, association|
                  next unless association.sortable?

                  alias_name = registrar_local.ensure_association_types(association)

                  association_sort_type = if alias_name
                                            imported_type = :"#{alias_name}_sort"
                                            registrar_local.type?(imported_type) ? imported_type : nil
                                          else
                                            association_resource = builder.resolve_association_resource(association)
                                            next unless association_resource
                                            next unless association_resource[:schema_class]
                                            next if visited.include?(association_resource[:schema_class])

                                            builder.build_sort_type_for_schema(
                                              association_resource[:schema_class],
                                              visited:,
                                              depth: depth + 1,
                                            )
                                          end

                  reference name, optional: true, to: association_sort_type if association_sort_type
                end
              end

              type_name
            end

            def build_sort_type_for_schema(association_schema, depth:, visited:)
              self.class.new(registrar, association_schema)
                .build_sort_type(depth:, visited:)
            end

            def type_name(base_name, depth)
              return base_name if depth.zero?

              schema_name = schema_class.name.demodulize.delete_suffix('Schema').underscore
              :"#{schema_name}_#{base_name}"
            end

            def has_sortable_content?(visited)
              has_sortable_attributes = schema_class.attributes.values.any?(&:sortable?)

              return true if has_sortable_attributes

              schema_class.associations.values.any? do |association|
                next false unless association.sortable?

                association_resource = resolve_association_resource(association)
                association_resource&.dig(:schema_class) && visited.exclude?(association_resource[:schema_class])
              end
            end

            def resolve_association_resource(association)
              return nil if association.polymorphic?

              resolved_schema = resolve_schema_from_association(association)
              return nil unless resolved_schema

              { schema_class: resolved_schema, sti: resolved_schema.discriminated? }
            end

            def resolve_schema_from_association(association)
              return association.schema_class if association.schema_class

              model_class = association.model_class
              return nil unless model_class

              reflection = model_class.reflect_on_association(association.name)
              return nil unless reflection

              infer_association_schema(reflection)
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
  end
end
