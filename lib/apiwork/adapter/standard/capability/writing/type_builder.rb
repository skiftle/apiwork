# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing < Adapter::Capability::Base
          class TypeBuilder
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
              build_enums
              build_payload_types
            end

            def build_payload_types
              build_payload_type(:create)
              build_payload_type(:update)
              build_nested_payload_union
            end

            def build_payload_type(action_name)
              if sti_base_schema?
                build_sti_payload_union(action_name)
              else
                build_standard_payload(action_name)
              end
            end

            def build_standard_payload(action_name)
              payload_type_name = :"#{action_name}_payload"

              return payload_type_name if registrar.type?(payload_type_name)

              builder = self

              registrar.object(payload_type_name, schema_class:) do
                builder.writable_params(self, action_name, nested: false)
              end

              payload_type_name
            end

            def writable_params(request, action_name, nested: false, target_schema_class: nil)
              target_schema_class ||= schema_class

              target_schema_class.attributes.each do |name, attribute|
                next unless attribute.writable_for?(action_name)

                param_options = build_attribute_options(attribute, action_name)
                request.param name, **param_options
              end

              target_schema_class.associations.each do |name, association|
                next unless association.writable_for?(action_name)

                param_options = build_association_options(association)
                request.param name, **param_options
              end
            end

            def build_nested_payload_union
              return unless schema_class.attributes.values.any?(&:writable?) ||
                            schema_class.associations.values.any?(&:writable?)

              build_nested_create_payload
              build_nested_update_payload
              build_nested_delete_payload
              build_nested_union
            end

            private

            def build_enums
              schema_class.attributes.each do |name, attribute|
                next unless attribute.enum&.any?

                registrar.enum(name, values: attribute.enum)
              end
            end

            def build_attribute_options(attribute, action_name)
              options = {
                deprecated: attribute.deprecated,
                description: attribute.description,
                example: attribute.example,
                format: attribute.format,
                nullable: attribute.nullable?,
                optional: action_name == :update || attribute.optional?,
                type: TypeMapper.map(attribute.type),
              }

              options[:min] = attribute.min if attribute.min
              options[:max] = attribute.max if attribute.max
              options[:of] = attribute.of if attribute.of
              options[:enum] = attribute.name if attribute.enum

              if attribute.element
                element = attribute.element

                if element.type == :array
                  options[:of] = { type: element.of_type }
                  options[:shape] = element.shape
                else
                  options[:shape] = element.shape
                  options[:discriminator] = element.discriminator if element.discriminator
                end
              end

              options
            end

            def build_association_options(association)
              association_payload_type = resolve_association_payload_type(association)

              options = {
                as: :"#{association.name}_attributes",
                deprecated: association.deprecated,
                description: association.description,
                example: association.example,
                nullable: association.nullable?,
                optional: true,
              }

              if association_payload_type
                if association.collection?
                  options[:type] = :array
                  options[:of] = association_payload_type
                else
                  options[:type] = association_payload_type
                end
              else
                options[:type] = association.collection? ? :array : :object
              end

              options
            end

            def resolve_association_payload_type(association)
              return nil if association.polymorphic?

              association_resource = resolve_association_resource(association)
              return nil unless association_resource&.schema_class

              alias_name = registrar.ensure_association_types(association)
              return nil unless alias_name

              association_payload_type = :"#{alias_name}_nested_payload"

              association_contract_class = registrar.find_contract_for_schema(association_resource.schema_class)

              if association_contract_class&.schema?
                association_registrar = ContractRegistrar.new(association_contract_class)
                sub_builder = self.class.new(association_registrar, association_resource.schema_class)
                sub_builder.build_nested_payload_union
              end

              association_payload_type
            end

            def resolve_association_resource(association)
              resolved_schema = resolve_schema_from_association(association)
              return nil unless resolved_schema

              sti = resolved_schema.discriminated?
              AssociationResource.for(resolved_schema, sti:)
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

            def build_nested_create_payload
              type_name = :nested_create_payload
              return if registrar.type?(type_name)

              builder = self
              id_type = primary_key_type

              registrar.object(type_name) do
                literal :_op, optional: true, value: 'create'
                param :id, optional: true, type: id_type
                builder.writable_params(self, :create, nested: true)
              end
            end

            def build_nested_update_payload
              type_name = :nested_update_payload
              return if registrar.type?(type_name)

              builder = self
              id_type = primary_key_type

              registrar.object(type_name) do
                literal :_op, optional: true, value: 'update'
                param :id, optional: true, type: id_type
                builder.writable_params(self, :update, nested: true)
              end
            end

            def build_nested_delete_payload
              type_name = :nested_delete_payload
              return if registrar.type?(type_name)

              id_type = primary_key_type

              registrar.object(type_name) do
                literal :_op, optional: true, value: 'delete'
                param :id, type: id_type
              end
            end

            def build_nested_union
              type_name = :nested_payload
              return if registrar.type?(type_name)

              create_qualified_name = registrar.scoped_type_name(:nested_create_payload)
              update_qualified_name = registrar.scoped_type_name(:nested_update_payload)
              delete_qualified_name = registrar.scoped_type_name(:nested_delete_payload)

              registrar.union(type_name, discriminator: :_op) do
                variant tag: 'create' do
                  reference create_qualified_name
                end
                variant tag: 'update' do
                  reference update_qualified_name
                end
                variant tag: 'delete' do
                  reference delete_qualified_name
                end
              end
            end

            def primary_key_type
              model_class = schema_class.model_class
              TypeMapper.map(model_class.type_for_attribute(model_class.primary_key).type)
            end

            def sti_base_schema?
              return false unless schema_class.discriminated?

              schema_class.union&.variants&.any?
            end

            def build_sti_payload_union(action_name)
              union_type_name = :"#{action_name}_payload"
              union = schema_class.union
              discriminator_name = union.discriminator
              builder = self
              registrar_local = registrar

              registrar.union(union_type_name, discriminator: discriminator_name) do
                union.variants.each do |tag, variant|
                  variant_schema_class = variant.schema_class
                  variant_name = variant_schema_class.name.demodulize.delete_suffix('Schema').underscore
                  variant_type_name = :"#{variant_name}_#{action_name}_payload"

                  unless registrar_local.api_registrar.type?(variant_type_name)
                    discriminator_column = union.column
                    as_column = discriminator_name != discriminator_column ? discriminator_column : nil
                    discriminator_optional = action_name == :update
                    needs_transform = union.needs_transform?
                    store_value = needs_transform && variant ? variant.type : nil

                    registrar_local.api_registrar.object(variant_type_name) do
                      literal discriminator_name, as: as_column, optional: discriminator_optional, store: store_value, value: tag.to_s
                      builder.writable_params(self, action_name, nested: false, target_schema_class: variant_schema_class)
                    end
                  end

                  variant tag: tag.to_s do
                    reference variant_type_name
                  end
                end
              end

              union_type_name
            end
          end
        end
      end
    end
  end
end
