# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering < Adapter::Capability::Base
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
              build_filter_type(depth: 0, visited: Set.new)
            end

            def build_filter_type(depth: 0, visited: Set.new)
              return nil if visited.include?(schema_class)
              return nil if depth >= MAX_RECURSION_DEPTH

              visited = visited.dup.add(schema_class)

              return nil unless has_filterable_content?(visited)

              type_name = type_name(:filter, depth)

              existing_type = registrar.type?(type_name)
              return type_name if existing_type

              builder = self
              registrar_local = registrar

              schema_class.attributes.each do |name, attribute|
                next unless attribute.filterable?
                next unless attribute.enum

                register_enum_filter(name)
              end

              type_options = { schema_class: schema_class }
              type_options = {} unless depth.zero?

              registrar.object(type_name, **type_options) do
                array :_and, optional: true do
                  reference type_name
                end
                array :_or, optional: true do
                  reference type_name
                end
                reference :_not, optional: true, to: type_name

                builder.schema_class.attributes.each do |name, attribute|
                  next unless attribute.filterable?
                  next if attribute.type == :unknown

                  filter_type = builder.filter_type_for(attribute)

                  if attribute.enum
                    reference name, optional: true, to: filter_type
                  elsif %i[object array union].include?(attribute.type)
                    reference name, optional: true, to: filter_type
                  else
                    union name, optional: true do
                      variant { of(attribute.type) }
                      variant { reference filter_type }
                    end
                  end
                end

                builder.schema_class.associations.each do |name, association|
                  next unless association.filterable?

                  alias_name = registrar_local.ensure_association_types(association)

                  association_filter_type = if alias_name
                                              imported_type = :"#{alias_name}_filter"
                                              registrar_local.type?(imported_type) ? imported_type : nil
                                            else
                                              association_resource = builder.resolve_association_resource(association)
                                              next unless association_resource
                                              next unless association_resource[:schema_class]
                                              next if visited.include?(association_resource[:schema_class])

                                              builder.build_filter_type_for_schema(
                                                association_resource[:schema_class],
                                                visited:,
                                                depth: depth + 1,
                                              )
                                            end

                  reference name, optional: true, to: association_filter_type if association_filter_type
                end
              end

              type_name
            end

            def build_filter_type_for_schema(association_schema, depth:, visited:)
              self.class.new(registrar, association_schema)
                .build_filter_type(depth:, visited:)
            end

            def filter_type_for(attribute)
              return enum_filter_type(attribute) if attribute.enum

              determine_filter_type(attribute.type, nullable: attribute.nullable?)
            end

            def determine_filter_type(attribute_type, nullable: false)
              base_type = case attribute_type
                          when :string then :string_filter
                          when :date then :date_filter
                          when :datetime then :datetime_filter
                          when :integer then :integer_filter
                          when :decimal then :decimal_filter
                          when :number then :number_filter
                          when :uuid then :uuid_filter
                          when :boolean then :boolean_filter
                          else :string_filter
                          end

              nullable ? :"nullable_#{base_type}" : base_type
            end

            def enum_filter_type(attribute)
              :"#{registrar.scoped_type_name(attribute.name)}_filter"
            end

            def register_enum_filter(enum_name)
              scoped_name = registrar.scoped_enum_name(enum_name)
              filter_name = :"#{scoped_name}_filter"

              return if registrar.api_registrar.type?(filter_name)

              registrar.api_registrar.union(filter_name) do
                variant { reference scoped_name }
                variant partial: true do
                  object do
                    reference :eq, to: scoped_name
                    array :in do
                      reference scoped_name
                    end
                  end
                end
              end
            end

            def type_name(base_name, depth)
              return base_name if depth.zero?

              schema_name = schema_class.name.demodulize.delete_suffix('Schema').underscore
              :"#{schema_name}_#{base_name}"
            end

            def has_filterable_content?(visited)
              has_filterable_attributes = schema_class.attributes.values.any? do |attribute|
                attribute.filterable? && attribute.type != :unknown
              end

              return true if has_filterable_attributes

              schema_class.associations.values.any? do |association|
                next false unless association.filterable?

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
