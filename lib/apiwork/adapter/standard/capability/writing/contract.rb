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
              build_nested_payload_union if writable_content?
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

              object type_name, schema_class: schema_class do
                params.each { |p| param p[:name], **p[:options] }
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

              params = collect_writable_params(:create)
              id_type = primary_key_type

              object :nested_create_payload do
                literal :_op, optional: true, value: 'create'
                param :id, optional: true, type: id_type
                params.each { |p| param p[:name], **p[:options] }
              end
            end

            def build_nested_update_payload
              return if type?(:nested_update_payload)

              params = collect_writable_params(:update)
              id_type = primary_key_type

              object :nested_update_payload do
                literal :_op, optional: true, value: 'update'
                param :id, optional: true, type: id_type
                params.each { |p| param p[:name], **p[:options] }
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

              create_name = scoped_type_name(:nested_create_payload)
              update_name = scoped_type_name(:nested_update_payload)
              delete_name = scoped_type_name(:nested_delete_payload)

              union :nested_payload, discriminator: :_op do
                variant(tag: 'create') { reference create_name }
                variant(tag: 'update') { reference update_name }
                variant(tag: 'delete') { reference delete_name }
              end
            end

            def build_sti_payload_union(action_name)
              union_type_name = :"#{action_name}_payload"
              schema_union = schema_class.union
              discriminator_name = schema_union.discriminator

              variants_data = schema_union.variants.map do |tag, variant|
                variant_schema = variant.schema_class
                variant_name = variant_schema.name.demodulize.delete_suffix('Schema').underscore

                {
                  column: schema_union.column,
                  schema: variant_schema,
                  store_value: schema_union.needs_transform? ? variant.type : nil,
                  tag: tag.to_s,
                  type_name: :"#{variant_name}_#{action_name}_payload",
                }
              end

              variants_data.each do |v|
                next if api_registrar.type?(v[:type_name])

                params = collect_writable_params(action_name, target_schema: v[:schema])
                as_column = discriminator_name != v[:column] ? v[:column] : nil
                discriminator_optional = action_name == :update
                store_value = v[:store_value]

                api_registrar.object(v[:type_name]) do
                  literal discriminator_name, as: as_column, optional: discriminator_optional, store: store_value, value: v[:tag]
                  params.each { |p| param p[:name], **p[:options] }
                end
              end

              union union_type_name, discriminator: discriminator_name do
                variants_data.each do |v|
                  variant(tag: v[:tag]) { reference v[:type_name] }
                end
              end
            end

            def collect_writable_params(action_name, target_schema: schema_class)
              params = []

              target_schema.attributes.each do |name, attribute|
                next unless attribute.writable_for?(action_name)

                params << { name:, options: attribute_options(attribute, action_name) }
              end

              target_schema.associations.each do |name, association|
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

              association_payload_type = :"#{alias_name}_nested_payload"

              if association_contract.schema?
                association_registrar = ContractRegistrar.new(association_contract)
                self.class.build_nested_payload_for(association_registrar, resolved_schema)
              end

              association_payload_type
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

            def writable_content?
              schema_class.attributes.values.any?(&:writable?) ||
                schema_class.associations.values.any?(&:writable?)
            end

            def sti_base_schema?
              schema_class.discriminated? && schema_class.union&.variants&.any?
            end

            def primary_key_type
              model = schema_class.model_class
              model.type_for_attribute(model.primary_key).type
            end

            class << self
              def build_nested_payload_for(registrar, target_schema)
                return unless target_schema.attributes.values.any?(&:writable?) ||
                              target_schema.associations.values.any?(&:writable?)

                build_nested_type_for(registrar, target_schema, :create)
                build_nested_type_for(registrar, target_schema, :update)
                build_nested_delete_for(registrar, target_schema)
                build_nested_union_for(registrar, target_schema)
              end

              private

              def build_nested_type_for(registrar, target_schema, action_name)
                type_name = :"nested_#{action_name}_payload"
                return if registrar.type?(type_name)

                params = collect_params_for(registrar, target_schema, action_name)
                id_type = target_schema.model_class.type_for_attribute(target_schema.model_class.primary_key).type

                registrar.object(type_name) do
                  literal :_op, optional: true, value: action_name.to_s
                  param :id, optional: true, type: id_type
                  params.each { |p| param p[:name], **p[:options] }
                end
              end

              def build_nested_delete_for(registrar, target_schema)
                type_name = :nested_delete_payload
                return if registrar.type?(type_name)

                id_type = target_schema.model_class.type_for_attribute(target_schema.model_class.primary_key).type

                registrar.object(type_name) do
                  literal :_op, optional: true, value: 'delete'
                  param :id, type: id_type
                end
              end

              def build_nested_union_for(registrar, target_schema)
                type_name = :nested_payload
                return if registrar.type?(type_name)

                create_name = registrar.scoped_type_name(:nested_create_payload)
                update_name = registrar.scoped_type_name(:nested_update_payload)
                delete_name = registrar.scoped_type_name(:nested_delete_payload)

                registrar.union(type_name, discriminator: :_op) do
                  variant(tag: 'create') { reference create_name }
                  variant(tag: 'update') { reference update_name }
                  variant(tag: 'delete') { reference delete_name }
                end
              end

              def collect_params_for(registrar, target_schema, action_name)
                params = []

                target_schema.attributes.each do |name, attribute|
                  next unless attribute.writable_for?(action_name)

                  params << { name:, options: attribute_options_for(attribute, action_name) }
                end

                target_schema.associations.each do |name, association|
                  next unless association.writable_for?(action_name)

                  params << { name:, options: association_options_for(registrar, target_schema, association) }
                end

                params
              end

              def attribute_options_for(attribute, action_name)
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

                options
              end

              def association_options_for(registrar, source_schema, association)
                payload_type = resolve_nested_association_type(registrar, source_schema, association)

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

              def resolve_nested_association_type(registrar, source_schema, association)
                return nil if association.polymorphic?

                resolved_schema = resolve_association_schema_for(source_schema, association)
                return nil unless resolved_schema

                association_contract = registrar.find_contract_for_schema(resolved_schema)
                return nil unless association_contract

                alias_name = resolved_schema.root_key.singular.to_sym
                registrar.import(association_contract, as: alias_name)

                association_payload_type = :"#{alias_name}_nested_payload"

                if association_contract.schema?
                  association_registrar = ContractRegistrar.new(association_contract)
                  build_nested_payload_for(association_registrar, resolved_schema)
                end

                association_payload_type
              end

              def resolve_association_schema_for(source_schema, association)
                return association.schema_class if association.schema_class

                model_class = association.model_class
                return nil unless model_class

                reflection = model_class.reflect_on_association(association.name)
                return nil unless reflection
                return nil if reflection.polymorphic?

                namespace = source_schema.name.deconstantize
                "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
              end
            end
          end
        end
      end
    end
  end
end
