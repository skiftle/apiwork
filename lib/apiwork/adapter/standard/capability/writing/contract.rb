# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing
          class Contract < Adapter::Capability::Contract::Base
            def build
              build_enums
              build_payload_types
              build_nested_payload_union if api_class.schemas.nested_writable?(schema_class)

              root_key = schema_class.root_key.singular.to_sym

              %i[create update].each do |action_name|
                next unless actions.key?(action_name)

                payload_type_name = :"#{action_name}_payload"
                next unless type?(payload_type_name)

                contract_action = action(action_name)
                next if contract_action.resets_request?

                contract_action.request do
                  body do
                    reference root_key, to: payload_type_name
                  end
                end
              end
            end

            private

            def build_enums
              schema_class.attributes.each do |name, attribute|
                next unless attribute.enum&.any?

                enum(name, values: attribute.enum)
              end
            end

            def build_payload_types
              build_payload_type(:create)
              build_payload_type(:update)
            end

            def build_payload_type(action_name)
              if sti_base_schema?
                build_sti_payload_union(action_name)
              else
                build_standard_payload(action_name)
              end
            end

            def build_standard_payload(action_name)
              type_name = :"#{action_name}_payload"
              return if type?(type_name)

              params = collect_writable_params(action_name)
              local_schema_class = schema_class

              object type_name, schema_class: schema_class do
                if local_schema_class.variant?
                  parent_union = local_schema_class.superclass.union
                  discriminator_name = parent_union.discriminator
                  as_column = discriminator_name != parent_union.column ? parent_union.column : nil
                  discriminator_optional = action_name == :update
                  store_value = parent_union.needs_transform? ? local_schema_class.model_class.sti_name : nil

                  literal discriminator_name, as: as_column, optional: discriminator_optional, store: store_value, value: local_schema_class.tag.to_s
                end

                params.each { |param_config| param param_config[:name], **param_config[:options] }
              end
            end

            def build_nested_payload_union
              build_nested_create_payload
              build_nested_update_payload
              build_nested_delete_payload
              build_nested_union
            end

            def build_nested_create_payload
              return if type?(:nested_create_payload)

              writable_params = collect_writable_params(:create)
              id_type = primary_key_type

              object :nested_create_payload do
                literal :_op, optional: true, value: 'create'
                param :id, optional: true, type: id_type
                writable_params.each { |param_config| param param_config[:name], **param_config[:options] }
              end
            end

            def build_nested_update_payload
              return if type?(:nested_update_payload)

              writable_params = collect_writable_params(:update)
              id_type = primary_key_type

              object :nested_update_payload do
                literal :_op, optional: true, value: 'update'
                param :id, optional: true, type: id_type
                writable_params.each { |param_config| param param_config[:name], **param_config[:options] }
              end
            end

            def build_nested_delete_payload
              return if type?(:nested_delete_payload)

              id_type = primary_key_type

              object :nested_delete_payload do
                literal :_op, optional: true, value: 'delete'
                param :id, type: id_type
              end
            end

            def build_nested_union
              return if type?(:nested_payload)

              create_type = scoped_type_name(:nested_create_payload)
              update_type = scoped_type_name(:nested_update_payload)
              delete_type = scoped_type_name(:nested_delete_payload)

              union :nested_payload, discriminator: :_op do
                variant(tag: 'create') { reference create_type }
                variant(tag: 'update') { reference update_type }
                variant(tag: 'delete') { reference delete_type }
              end
            end

            def build_sti_payload_union(action_name)
              union_type_name = :"#{action_name}_payload"
              schema_union = schema_class.union
              discriminator_name = schema_union.discriminator

              variant_refs = schema_union.variants.filter_map do |tag, variant|
                variant_schema = variant.schema_class
                variant_contract = find_contract_for_schema(variant_schema)
                next unless variant_contract

                alias_name = variant_schema.root_key.singular.to_sym
                import(variant_contract, as: alias_name)

                { tag: tag.to_s, type: :"#{alias_name}_#{action_name}_payload" }
              end

              union union_type_name, discriminator: discriminator_name do
                variant_refs.each do |v|
                  variant(tag: v[:tag]) { reference v[:type] }
                end
              end
            end

            def collect_writable_params(action_name)
              params = []

              schema_class.attributes.each do |name, attribute|
                next unless attribute.writable_for?(action_name)

                params << { name:, options: attribute_options(attribute, action_name) }
              end

              schema_class.associations.each do |name, association|
                next unless association.writable_for?(action_name)

                params << { name:, options: association_options(association) }
              end

              params
            end

            def attribute_options(attribute, action_name)
              options = {
                deprecated: attribute.deprecated,
                description: attribute.description,
                example: attribute.example,
                format: attribute.format,
                nullable: attribute.nullable?,
                optional: action_name == :update || attribute.optional?,
                type: attribute.type,
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

            def association_options(association)
              payload_type = resolve_association_payload_type(association)

              options = {
                as: :"#{association.name}_attributes",
                deprecated: association.deprecated,
                description: association.description,
                example: association.example,
                nullable: association.nullable?,
                optional: true,
              }

              if payload_type
                if association.collection?
                  options[:type] = :array
                  options[:of] = payload_type
                else
                  options[:type] = payload_type
                end
              else
                options[:type] = association.collection? ? :array : :object
              end

              options
            end

            def resolve_association_payload_type(association)
              return nil if association.polymorphic?

              resolved_schema = resolve_association_schema(association)
              return nil unless resolved_schema

              association_contract = find_contract_for_schema(resolved_schema)
              return nil unless association_contract

              alias_name = resolved_schema.root_key.singular.to_sym
              import(association_contract, as: alias_name)

              :"#{alias_name}_nested_payload"
            end

            def resolve_association_schema(association)
              return association.schema_class if association.schema_class

              model_class = association.model_class
              return nil unless model_class

              reflection = model_class.reflect_on_association(association.name)
              return nil unless reflection
              return nil if reflection.polymorphic?

              namespace = schema_class.name.deconstantize
              "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
            end

            def api_class
              registrar.contract_class.api_class
            end

            def sti_base_schema?
              schema_class.discriminated? && schema_class.union&.variants&.any?
            end

            def primary_key_type
              model = schema_class.model_class
              model.type_for_attribute(model.primary_key).type
            end
          end
        end
      end
    end
  end
end
