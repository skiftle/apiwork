# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      class TypeBuilder
        MAX_RECURSION_DEPTH = 3

        class << self
          def sti_base_schema?(schema_class)
            return false unless schema_class.respond_to?(:sti_base?) && schema_class.sti_base?

            schema_class.respond_to?(:variants) && schema_class.variants&.any?
          end

          def determine_filter_type(attr_type, nullable: false)
            base_type = case attr_type
                        when :string
                          :string_filter
                        when :date
                          :date_filter
                        when :datetime
                          :datetime_filter
                        when :integer
                          :integer_filter
                        when :decimal, :float
                          :decimal_filter
                        when :uuid
                          :uuid_filter
                        when :boolean
                          :boolean_filter
                        else
                          :string_filter # Default fallback
                        end

            nullable ? :"nullable_#{base_type}" : base_type
          end

          def filter_type_for(attribute_definition, contract_class)
            return enum_filter_type(attribute_definition, contract_class) if attribute_definition.enum

            determine_filter_type(attribute_definition.type, nullable: attribute_definition.nullable?)
          end

          def enum_filter_type(attribute_definition, contract_class)
            scoped_enum_name = Descriptor.scoped_enum_name(contract_class, attribute_definition.name)
            :"#{scoped_enum_name}_filter"
          end

          def build_filter_type(contract_class, schema_class, visited: Set.new, depth: 0)
            return nil if visited.include?(schema_class)
            return nil if depth >= MAX_RECURSION_DEPTH

            visited = visited.dup.add(schema_class)

            Descriptor.ensure_filter_descriptors(schema_class, api_class: contract_class.api_class)

            type_name = build_type_name(schema_class, :filter, depth)

            existing = Descriptor.resolve_type(type_name, contract_class: contract_class)
            return type_name if existing

            Descriptor.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              param :_and, type: :array, of: type_name, required: false
              param :_or, type: :array, of: type_name, required: false
              param :_not, type: type_name, required: false

              schema_class.attribute_definitions.each do |name, attribute_definition|
                next unless attribute_definition.filterable?
                next if attribute_definition.type == :unknown # Skip unknown types - not filterable

                filter_type = TypeBuilder.filter_type_for(attribute_definition, contract_class)

                if attribute_definition.enum
                  param name, type: filter_type, required: false
                else
                  param name, type: :union, required: false do
                    variant type: Generator.map_type(attribute_definition.type)
                    variant type: filter_type
                  end
                end
              end

              schema_class.association_definitions.each do |name, association_definition|
                next unless association_definition.filterable?

                association_resource = TypeBuilder.resolve_association_resource(association_definition)
                next unless association_resource
                next if visited.include?(association_resource)

                import_alias = TypeBuilder.auto_import_association_contract(
                  contract_class,
                  association_resource,
                  visited
                )

                association_filter_type = if import_alias
                                            :"#{import_alias}_filter"
                                          else
                                            TypeBuilder.build_filter_type(
                                              contract_class,
                                              association_resource,
                                              visited: visited,
                                              depth: depth + 1
                                            )
                                          end

                param name, type: association_filter_type, required: false if association_filter_type
              end
            end

            type_name
          end

          def build_sort_type(contract_class, schema_class, visited: Set.new, depth: 0)
            return nil if visited.include?(schema_class)
            return nil if depth >= MAX_RECURSION_DEPTH

            visited = visited.dup.add(schema_class)

            Descriptor.ensure_sort_descriptor(schema_class, api_class: contract_class.api_class)

            type_name = build_type_name(schema_class, :sort, depth)

            existing = Descriptor.resolve_type(type_name, contract_class: contract_class)
            return type_name if existing

            Descriptor.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              schema_class.attribute_definitions.each do |name, attribute_definition|
                next unless attribute_definition.sortable?

                param name, type: :sort_direction, required: false
              end

              schema_class.association_definitions.each do |name, association_definition|
                next unless association_definition.sortable?

                association_resource = TypeBuilder.resolve_association_resource(association_definition)
                next unless association_resource
                next if visited.include?(association_resource)

                import_alias = TypeBuilder.auto_import_association_contract(
                  contract_class,
                  association_resource,
                  visited
                )

                association_sort_type = if import_alias
                                          :"#{import_alias}_sort"
                                        else
                                          TypeBuilder.build_sort_type(
                                            contract_class,
                                            association_resource,
                                            visited: visited,
                                            depth: depth + 1
                                          )
                                        end

                param name, type: association_sort_type, required: false if association_sort_type
              end
            end

            type_name
          end

          def build_page_type(contract_class, schema_class)
            resolved_max_page_size = Configuration::Resolver.resolve(:max_page_size, contract_class: contract_class, schema_class: schema_class,
                                                                                     api_class: contract_class.api_class)

            type_name = build_type_name(schema_class, :page, 1)

            existing = Descriptor.resolve_type(type_name, contract_class: contract_class)
            return type_name if existing

            Descriptor.register_type(type_name, api_class: contract_class.api_class) do
              param :number, type: :integer, required: false, min: 1
              param :size, type: :integer, required: false, min: 1, max: resolved_max_page_size
            end

            type_name
          end

          def resolve_association_resource(association_definition)
            return :polymorphic if association_definition.polymorphic?

            if association_definition.schema_class
              resolved_schema = if association_definition.schema_class.is_a?(Class)
                                  association_definition.schema_class
                                else
                                  begin
                                    association_definition.schema_class.constantize
                                  rescue NameError
                                    nil
                                  end
                                end

              return { sti: true, schema: resolved_schema } if resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?

              return resolved_schema
            end

            model_class = association_definition.model_class
            return nil unless model_class

            reflection = model_class.reflect_on_association(association_definition.name)
            return nil unless reflection

            association_model_class = begin
              reflection.klass
            rescue ActiveRecord::AssociationNotFoundError, NameError
              nil
            end
            return nil unless association_model_class

            # FIXME: Hardcoded assumption about schema class naming convention!!!
            schema_class_name = "Api::V1::#{association_model_class.name.demodulize}Schema"
            resolved_schema = begin
              schema_class_name.constantize
            rescue NameError
              nil
            end

            return { sti: true, schema: resolved_schema } if resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?

            resolved_schema
          end

          def build_include_type(contract_class, schema_class, visited: Set.new, depth: 0)
            type_name = build_type_name(schema_class, :include, depth)

            existing = Descriptor.resolve_type(type_name, contract_class: contract_class)
            return type_name if existing
            return type_name if depth >= MAX_RECURSION_DEPTH

            visited = visited.dup.add(schema_class)

            Descriptor.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              schema_class.association_definitions.each do |name, association_definition|
                association_resource = TypeBuilder.resolve_association_resource(association_definition)
                next unless association_resource

                is_sti = association_resource.is_a?(Hash) && association_resource[:sti]
                actual_schema = is_sti ? association_resource[:schema] : association_resource

                if visited.include?(actual_schema)
                  param name, type: :boolean, required: false unless association_definition.always_included?
                else
                  import_alias = TypeBuilder.auto_import_association_contract(
                    contract_class,
                    actual_schema,
                    visited
                  )

                  association_include_type = if import_alias
                                               :"#{import_alias}_include"
                                             else
                                               TypeBuilder.build_include_type(
                                                 contract_class,
                                                 actual_schema,
                                                 visited: visited,
                                                 depth: depth + 1
                                               )
                                             end

                  if association_definition.always_included?
                    param name, type: association_include_type, required: false
                  else
                    param name, type: :union, required: false do
                      variant type: :boolean
                      variant type: association_include_type
                    end
                  end
                end
              end
            end

            type_name
          end

          def build_association_type(contract_class, association_definition, visited: Set.new)
            return build_polymorphic_association_type(contract_class, association_definition, visited: visited) if association_definition.polymorphic?

            association_schema = resolve_association_resource(association_definition)
            return nil unless association_schema

            if association_schema.is_a?(Hash) && association_schema[:sti]
              return build_sti_association_type(contract_class, association_definition, association_schema[:schema],
                                                visited: visited)
            end

            return nil if visited.include?(association_schema)

            import_alias = auto_import_association_contract(contract_class, association_schema, visited)

            visited = visited.dup.add(association_schema)

            if import_alias
              association_contract = Base.find_contract_for_schema(association_schema)
              build_response_type(association_contract, association_schema, visited: Set.new) if association_contract

              return import_alias
            end

            association_contract_class = Class.new(Base) do
              schema association_schema
            end

            resource_type_name = nil

            unless Descriptor.resolve_type(resource_type_name, contract_class: association_contract_class)
              Descriptor.register_type(resource_type_name, scope: association_contract_class,
                                                           api_class: association_contract_class.api_class) do
                association_schema.attribute_definitions.each do |name, attribute_definition|
                  param name, type: Generator.map_type(attribute_definition.type), required: false
                end

                association_schema.association_definitions.each do |name, nested_association_definition|
                  nested_type = TypeBuilder.build_association_type(association_contract_class,
                                                                   nested_association_definition, visited: visited)

                  if nested_type
                    if nested_association_definition.singular?
                      param name, type: nested_type, required: false, nullable: nested_association_definition.nullable?
                    elsif nested_association_definition.collection?
                      param name, type: :array, of: nested_type, required: false,
                                  nullable: nested_association_definition.nullable?
                    end
                  elsif nested_association_definition.singular?
                    param name, type: :object, required: false, nullable: nested_association_definition.nullable?
                  elsif nested_association_definition.collection?
                    param name, type: :array, required: false, nullable: nested_association_definition.nullable?
                  end
                end
              end
            end

            Descriptor.scoped_type_name(association_contract_class, resource_type_name)
          end

          def build_polymorphic_association_type(contract_class, association_definition, visited: Set.new)
            polymorphic = association_definition.polymorphic
            return nil unless polymorphic&.any?

            union_type_name = :"#{association_definition.name}_polymorphic"

            existing = Descriptor.resolve_type(union_type_name, contract_class: contract_class)
            return existing if existing

            union_definition = UnionDefinition.new(contract_class, discriminator: association_definition.discriminator)

            polymorphic.each do |tag, schema_class|
              import_alias = auto_import_association_contract(contract_class, schema_class, visited)
              next unless import_alias

              union_definition.variant(type: import_alias, tag: tag.to_s)
            end

            union_data = union_definition.serialize

            Descriptor.register_union(union_type_name, union_data,
                                      scope: contract_class, api_class: contract_class.api_class)

            union_type_name
          end

          def build_sti_union(contract_class, schema_class, union_type_name:, visited: Set.new, &variant_builder)
            variants = schema_class.variants
            return nil unless variants&.any?

            discriminator_name = schema_class.discriminator_name
            union_definition = UnionDefinition.new(contract_class, discriminator: discriminator_name)

            variants.each do |tag, variant_data|
              variant_schema = variant_data[:schema]

              variant_type = yield(contract_class, variant_schema, tag, visited)
              next unless variant_type

              union_definition.variant(type: variant_type, tag: tag.to_s)
            end

            union_data = union_definition.serialize

            Descriptor.register_union(union_type_name, union_data,
                                      scope: contract_class, api_class: contract_class.api_class)

            union_type_name
          end

          def build_sti_association_type(contract_class, association_definition, schema_class, visited: Set.new)
            union_type_name = :"#{association_definition.name}_sti"

            build_sti_union(contract_class, schema_class, union_type_name: union_type_name,
                                                          visited: visited) do |contract, variant_schema, _tag, visit_set|
              auto_import_association_contract(contract, variant_schema, visit_set)
            end
          end

          def build_sti_response_union_type(contract_class, schema_class, visited: Set.new)
            union_type_name = schema_class.root_key.singular.to_sym

            build_sti_union(contract_class, schema_class, union_type_name: union_type_name,
                                                          visited: visited) do |contract, variant_schema, _tag, visit_set|
              auto_import_association_contract(contract, variant_schema, visit_set)
            end
          end

          def auto_import_association_contract(parent_contract, association_schema, visited)
            return nil if visited.include?(association_schema)

            association_contract = Base.find_contract_for_schema(association_schema)
            return nil unless association_contract

            alias_name = association_schema.root_key.singular.to_sym

            parent_contract.import(association_contract, as: alias_name) unless parent_contract.imports.key?(alias_name)

            if association_contract.schema?
              build_filter_type(association_contract, association_schema, visited: Set.new, depth: 0)
              build_sort_type(association_contract, association_schema, visited: Set.new, depth: 0)
              build_include_type(association_contract, association_schema, visited: Set.new, depth: 0)
              build_nested_payload_union(association_contract, association_schema)
              build_response_type(association_contract, association_schema, visited: Set.new)
            end

            alias_name
          end

          def build_contract_enums(contract_class, schema_class)
            api_class = contract_class.api_class

            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.enum&.any?

              Descriptor.register_enum(name, attribute_definition.enum, scope: contract_class, api_class: api_class)
            end
          end

          def build_nested_payload_union(contract_class, schema_class)
            return unless schema_class.attribute_definitions.any? { |_, ad| ad.writable? } ||
                          schema_class.association_definitions.any? { |_, ad| ad.writable? }

            api_class = contract_class.api_class

            create_type_name = :nested_create_payload
            adapter = api_class.adapter

            unless Descriptor.resolve_type(create_type_name, contract_class: contract_class)
              Descriptor.register_type(create_type_name, scope: contract_class, api_class: api_class) do
                param :_type, type: :literal, value: 'create', required: true
                adapter.build_nested_writable_params(self, schema_class, :create, nested: true)
                if schema_class.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
                  param :_destroy, type: :boolean, required: false
                end
              end
            end

            update_type_name = :nested_update_payload
            unless Descriptor.resolve_type(update_type_name, contract_class: contract_class)
              Descriptor.register_type(update_type_name, scope: contract_class, api_class: api_class) do
                param :_type, type: :literal, value: 'update', required: true
                adapter.build_nested_writable_params(self, schema_class, :update, nested: true)
                if schema_class.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
                  param :_destroy, type: :boolean, required: false
                end
              end
            end

            nested_payload_type_name = :nested_payload
            return if Descriptor.resolve_type(nested_payload_type_name, contract_class: contract_class)

            create_qualified_name = Descriptor.scoped_type_name(contract_class, create_type_name)
            update_qualified_name = Descriptor.scoped_type_name(contract_class, update_type_name)

            union_definition = UnionDefinition.new(contract_class, discriminator: :_type)
            union_definition.variant(type: create_qualified_name, tag: 'create')
            union_definition.variant(type: update_qualified_name, tag: 'update')
            union_data = union_definition.serialize

            Descriptor.register_union(nested_payload_type_name, union_data,
                                      scope: contract_class, api_class: api_class)
          end

          def build_response_type(contract_class, schema_class, visited: Set.new)
            return if visited.include?(schema_class)

            visited.dup.add(schema_class)

            return if sti_base_schema?(schema_class)

            root_key = schema_class.root_key.singular.to_sym
            resource_type_name = Descriptor.scoped_type_name(contract_class, nil)

            return if Descriptor.resolve_type(resource_type_name, contract_class: contract_class)

            Descriptor.register_type(root_key, scope: contract_class, api_class: contract_class.api_class) do
              if schema_class.respond_to?(:sti_variant?) && schema_class.sti_variant?
                parent_schema = schema_class.superclass
                discriminator_name = parent_schema.discriminator_name
                variant_tag = schema_class.variant_tag.to_s

                param discriminator_name, type: :literal, value: variant_tag, required: true
              end

              assoc_type_map = {}
              schema_class.association_definitions.each do |name, association_definition|
                result = TypeBuilder.build_association_type(contract_class, association_definition, visited: Set.new)
                assoc_type_map[name] = result
              end

              schema_class.attribute_definitions.each do |name, attribute_definition|
                if attribute_definition.enum
                  enum_values = attribute_definition.enum
                  Descriptor.register_enum(name, enum_values, scope: contract_class,
                                                              api_class: contract_class.api_class)
                end

                enum_option = attribute_definition.enum ? { enum: name } : {}
                param name,
                      type: Generator.map_type(attribute_definition.type),
                      required: false,
                      description: attribute_definition.description,
                      example: attribute_definition.example,
                      format: attribute_definition.format,
                      deprecated: attribute_definition.deprecated,
                      **enum_option
              end

              schema_class.association_definitions.each do |name, association_definition|
                assoc_type = assoc_type_map[name]
                is_required = association_definition.always_included?

                if assoc_type
                  if association_definition.singular?
                    param name, type: assoc_type, required: is_required, nullable: association_definition.nullable?
                  elsif association_definition.collection?
                    param name, type: :array, of: assoc_type, required: is_required,
                                nullable: association_definition.nullable?
                  end
                elsif association_definition.singular?
                  param name, type: :object, required: is_required, nullable: association_definition.nullable?
                elsif association_definition.collection?
                  param name, type: :array, of: :object, required: is_required, nullable: association_definition.nullable?
                end
              end
            end
          end

          private

          def build_type_name(schema_class, base_name, depth)
            return base_name if depth.zero?

            schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
            :"#{schema_name}_#{base_name}"
          end
        end
      end
    end
  end
end
