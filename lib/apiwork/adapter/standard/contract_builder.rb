# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      module ContractBuilder
        class << self
          def generate_query_params(definition, schema_class)
            contract_class = definition.contract_class

            filter_type = TypeBuilder.build_filter_type(contract_class, schema_class)
            sort_type = TypeBuilder.build_sort_type(contract_class, schema_class)

            if filter_type
              definition.param :filter, type: :union, required: false do
                variant type: filter_type
                variant type: :array, of: filter_type
              end
            end

            if sort_type
              definition.param :sort, type: :union, required: false do
                variant type: sort_type
                variant type: :array, of: sort_type
              end
            end

            page_type = TypeBuilder.build_page_type(contract_class, schema_class)
            definition.param :page, type: page_type, required: false

            include_type = TypeBuilder.build_include_type(contract_class, schema_class)
            definition.param :include, type: include_type, required: false
          end

          def generate_writable_request(definition, schema_class, context)
            root_key = schema_class.root_key.singular.to_sym
            contract_class = definition.contract_class

            if Helpers.sti_base_schema?(schema_class)
              payload_type_name = generate_sti_request_union(contract_class, schema_class, context)
            else
              payload_type_name = :"#{context}_payload"

              unless contract_class.resolve_type(payload_type_name)
                contract_class.register_type(payload_type_name) do
                  ContractBuilder.generate_writable_params(self, schema_class, context, nested: false)
                end
              end
            end

            definition.param root_key, type: payload_type_name, required: true
          end

          def generate_writable_params(definition, schema_class, context, nested: false)
            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.writable_for?(context)

              param_options = {
                type: TypeMapper.map(attribute_definition.type),
                required: attribute_definition.required?,
                nullable: attribute_definition.nullable?,
                description: attribute_definition.description,
                example: attribute_definition.example,
                format: attribute_definition.format,
                deprecated: attribute_definition.deprecated,
                attribute_definition: attribute_definition
              }

              param_options[:min] = attribute_definition.min if attribute_definition.min
              param_options[:max] = attribute_definition.max if attribute_definition.max

              param_options[:enum] = name if attribute_definition.enum

              definition.param name, **param_options
            end

            schema_class.association_definitions.each do |name, association_definition|
              next unless association_definition.writable_for?(context)

              association_schema = Helpers.resolve_association_resource(association_definition, schema_class)
              association_payload_type = nil

              association_contract = nil
              if association_schema
                import_alias = Helpers.auto_import_association_contract(
                  definition.contract_class,
                  association_schema,
                  Set.new
                )

                if import_alias
                  association_payload_type = :"#{import_alias}_nested_payload"

                  association_contract = definition.contract_class.find_contract_for_schema(association_schema)
                end
              end

              param_options = {
                required: false,
                nullable: association_definition.nullable?,
                as: "#{name}_attributes".to_sym,
                description: association_definition.description,
                example: association_definition.example,
                deprecated: association_definition.deprecated
              }

              param_options[:type_contract_class] = association_contract if association_contract

              if association_payload_type
                if association_definition.collection?
                  param_options[:type] = :array
                  param_options[:of] = association_payload_type
                else
                  param_options[:type] = association_payload_type
                end
              else
                param_options[:type] = association_definition.collection? ? :array : :object
              end

              definition.param name, **param_options
            end
          end

          def generate_sti_request_union(contract_class, schema_class, context)
            union_type_name = :"#{context}_payload"
            discriminator_name = schema_class.discriminator_name

            TypeBuilder.build_sti_union(contract_class, schema_class,
                                        union_type_name: union_type_name) do |contract, variant_schema, tag, _visited|
              variant_schema_name = variant_schema.name.demodulize.underscore.gsub(/_schema$/, '')
              variant_type_name = :"#{variant_schema_name}_#{context}_payload"

              unless contract.resolve_type(variant_type_name)
                contract.register_type(variant_type_name) do
                  param discriminator_name, type: :literal, value: tag.to_s, required: true

                  ContractBuilder.generate_writable_params(self, variant_schema, context, nested: false)
                end
              end

              contract.scoped_type_name(variant_type_name)
            end
          end

          def generate_single_response(definition, schema_class)
            root_key = schema_class.root_key.singular.to_sym
            contract_class = definition.contract_class
            resource_type_name = resolve_resource_type_name(contract_class, schema_class)

            definition.instance_variable_set(:@unwrapped_union, true)
            definition.instance_variable_set(:@unwrapped_union_discriminator, :ok)

            definition.param :ok, type: :boolean, required: true
            definition.param root_key, type: resource_type_name, required: false
            definition.param :meta, type: :object, required: false

            definition.param :issues, type: :array, of: :issue, required: false
          end

          def generate_collection_response(definition, schema_class)
            root_key_plural = schema_class.root_key.plural.to_sym
            contract_class = definition.contract_class
            resource_type_name = resolve_resource_type_name(contract_class, schema_class)

            definition.instance_variable_set(:@unwrapped_union, true)
            definition.instance_variable_set(:@unwrapped_union_discriminator, :ok)

            definition.param :ok, type: :boolean, required: true
            definition.param root_key_plural, type: :array, of: resource_type_name, required: false
            definition.param :meta, type: :object, required: false do
              param :pagination, type: :pagination, required: true
            end

            definition.param :issues, type: :array, of: :issue, required: false
          end

          def resolve_resource_type_name(contract_class, schema_class)
            if Helpers.sti_base_schema?(schema_class)
              TypeBuilder.build_sti_response_union_type(contract_class, schema_class)
            else
              root_key = schema_class.root_key.singular.to_sym
              resource_type_name = contract_class.scoped_type_name(nil)

              register_resource_type(contract_class, schema_class, root_key) unless contract_class.resolve_type(resource_type_name)

              resource_type_name
            end
          end

          def register_resource_type(contract_class, schema_class, type_name)
            assoc_type_map = {}
            schema_class.association_definitions.each do |name, association_definition|
              assoc_type_map[name] = TypeBuilder.build_association_type(contract_class, schema_class, association_definition)
            end

            TypeBuilder.build_enums(contract_class, schema_class)

            contract_class.register_type(type_name) do
              schema_class.attribute_definitions.each do |name, attribute_definition|
                enum_option = attribute_definition.enum ? { enum: name } : {}

                param name,
                      type: TypeMapper.map(attribute_definition.type),
                      required: false,
                      description: attribute_definition.description,
                      example: attribute_definition.example,
                      format: attribute_definition.format,
                      deprecated: attribute_definition.deprecated,
                      **enum_option
              end

              schema_class.association_definitions.each do |name, association_definition|
                assoc_type = assoc_type_map[name]

                base_options = {
                  required: association_definition.always_included?,
                  nullable: association_definition.nullable?,
                  description: association_definition.description,
                  example: association_definition.example,
                  deprecated: association_definition.deprecated
                }

                if association_definition.singular?
                  param name, type: assoc_type || :object, **base_options
                elsif association_definition.collection?
                  if assoc_type
                    param name, type: :array, of: assoc_type, **base_options
                  else
                    param name, type: :array, **base_options
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
