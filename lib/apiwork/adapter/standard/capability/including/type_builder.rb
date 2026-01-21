# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
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
              build_include_type(depth: 0, visited: Set.new)
            end

            def build_include_type(depth: 0, visited: Set.new)
              return nil unless schema_class.associations.any?
              return nil unless has_includable_params?(depth:, visited:)

              type_name = type_name(:include, depth)

              existing_type = registrar.type?(type_name)
              return type_name if existing_type
              return type_name if depth >= MAX_RECURSION_DEPTH

              visited = visited.dup.add(schema_class)

              builder = self
              registrar_local = registrar

              registrar.object(type_name) do
                builder.schema_class.associations.each do |name, association|
                  if association.polymorphic?
                    boolean name, optional: true unless association.include == :always
                    next
                  end

                  association_resource = builder.resolve_association_resource(association)
                  next unless association_resource
                  next unless association_resource[:schema_class]

                  if visited.include?(association_resource[:schema_class])
                    boolean name, optional: true unless association.include == :always
                  else
                    alias_name = registrar_local.ensure_association_types(association)

                    association_include_type = if alias_name
                                                 imported_type = :"#{alias_name}_include"
                                                 registrar_local.type?(imported_type) ? imported_type : nil
                                               else
                                                 builder.build_include_type_for_schema(
                                                   association_resource[:schema_class],
                                                   visited:,
                                                   depth: depth + 1,
                                                 )
                                               end

                    if association_include_type.nil?
                      boolean name, optional: true unless association.include == :always
                    elsif association.include == :always
                      reference name, optional: true, to: association_include_type
                    else
                      union name, optional: true do
                        variant { boolean }
                        variant { reference association_include_type }
                      end
                    end
                  end
                end
              end

              type_name
            end

            def has_includable_params?(depth:, visited:)
              return false if depth >= MAX_RECURSION_DEPTH

              new_visited = visited.dup.add(schema_class)

              schema_class.associations.values.any? do |association|
                if association.polymorphic?
                  association.include != :always
                else
                  association_resource = resolve_association_resource(association)
                  next false unless association_resource
                  next false unless association_resource[:schema_class]

                  if new_visited.include?(association_resource[:schema_class])
                    association.include != :always
                  elsif association.include == :always
                    nested_builder = self.class.new(registrar, association_resource[:schema_class])
                    nested_builder.has_includable_params?(depth: depth + 1, visited: new_visited)
                  else
                    true
                  end
                end
              end
            end

            def build_include_type_for_schema(association_schema, depth:, visited:)
              self.class.new(registrar, association_schema)
                .build_include_type(depth:, visited:)
            end

            def type_name(base_name, depth)
              return base_name if depth.zero?

              schema_name = schema_class.name.demodulize.delete_suffix('Schema').underscore
              :"#{schema_name}_#{base_name}"
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
