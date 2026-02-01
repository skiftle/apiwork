# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing
          class ContractBuilder < Adapter::Capability::Contract::Base
            def build
              build_enums
              build_payload_types
              build_nested_payload_union if api_class.representation_registry.nested_writable?(representation_class)

              %i[create update].each do |action_name|
                next unless scope.action?(action_name)

                payload_type_name = :"#{action_name}_payload"
                next unless type?(payload_type_name)

                contract_action = action(action_name)
                next if contract_action.resets_request?

                contract_action.request do |request|
                  request.body do |body|
                    body.reference(representation_class.root_key.singular.to_sym, to: payload_type_name)
                  end
                end
              end
            end

            private

            def build_enums
              representation_class.attributes.each do |name, attribute|
                next unless attribute.enum&.any?

                enum(name, values: attribute.enum)
              end
            end

            def build_payload_types
              build_payload_type(:create)
              build_payload_type(:update)
            end

            def build_payload_type(action_name)
              if sti_base_representation?
                build_sti_payload_union(action_name)
              else
                build_standard_payload(action_name)
              end
            end

            def build_standard_payload(action_name)
              type_name = :"#{action_name}_payload"
              return if type?(type_name)

              object(type_name, representation_class: representation_class) do |object|
                if representation_class.subclass?
                  parent_inheritance = representation_class.superclass.inheritance

                  object.literal(
                    parent_inheritance.column,
                    optional: action_name == :update,
                    store: parent_inheritance.needs_transform? ? representation_class.model_class.sti_name : nil,
                    value: representation_class.sti_name,
                  )
                end

                collect_writable_params(action_name).each do |param_config|
                  object.param(param_config[:name], **param_config[:options])
                end
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

              object(:nested_create_payload) do |object|
                object.literal(Constants::OP, optional: true, value: 'create')
                object.param(:id, optional: true, type: primary_key_type)
                collect_writable_params(:create).each do |param_config|
                  object.param(param_config[:name], **param_config[:options])
                end
              end
            end

            def build_nested_update_payload
              return if type?(:nested_update_payload)

              object(:nested_update_payload) do |object|
                object.literal(Constants::OP, optional: true, value: 'update')
                object.param(:id, optional: true, type: primary_key_type)
                collect_writable_params(:update).each do |param_config|
                  object.param(param_config[:name], **param_config[:options])
                end
              end
            end

            def build_nested_delete_payload
              return if type?(:nested_delete_payload)

              object(:nested_delete_payload) do |object|
                object.literal(Constants::OP, optional: true, value: 'delete')
                object.param(:id, type: primary_key_type)
              end
            end

            def build_nested_union
              return if type?(:nested_payload)

              union(:nested_payload, discriminator: Constants::OP) do |union|
                union.variant(tag: 'create') do |element|
                  element.reference(scoped_type_name(:nested_create_payload))
                end
                union.variant(tag: 'update') do |element|
                  element.reference(scoped_type_name(:nested_update_payload))
                end
                union.variant(tag: 'delete') do |element|
                  element.reference(scoped_type_name(:nested_delete_payload))
                end
              end
            end

            def build_sti_payload_union(action_name)
              representation_inheritance = representation_class.inheritance

              variant_refs = representation_inheritance.subclasses.filter_map do |subclass|
                subclass_contract = find_contract_for_representation(subclass)
                next unless subclass_contract

                alias_name = subclass.root_key.singular.to_sym
                import(subclass_contract, as: alias_name)

                { tag: subclass.sti_name, type: :"#{alias_name}_#{action_name}_payload" }
              end

              union(:"#{action_name}_payload", discriminator: representation_inheritance.column) do |union|
                variant_refs.each do |variant_ref|
                  union.variant(tag: variant_ref[:tag]) do |element|
                    element.reference(variant_ref[:type])
                  end
                end
              end
            end

            def collect_writable_params(action_name)
              params = []

              representation_class.attributes.each do |name, attribute|
                next unless attribute.writable_for?(action_name)

                params << { name:, options: attribute_options(attribute, action_name) }
              end

              representation_class.associations.each do |name, association|
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

              polymorphic_options = polymorphic_type_options(attribute)
              options.merge!(polymorphic_options) if polymorphic_options

              options
            end

            def polymorphic_type_options(attribute)
              association = representation_class.polymorphic_association_for_type_column(attribute.name)
              return nil unless association

              type_mapping = {}
              allowed_values = []

              association.polymorphic.each do |poly_representation_class|
                api_value = poly_representation_class.polymorphic_name
                rails_type = poly_representation_class.model_class.polymorphic_name
                type_mapping[api_value] = rails_type
                allowed_values << api_value
              end

              {
                enum: allowed_values,
                transform: ->(value) { type_mapping[value] || value },
              }
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

              resolved_representation_class = resolve_association_representation_class(association)
              return nil unless resolved_representation_class

              association_contract = find_contract_for_representation(resolved_representation_class)
              return nil unless association_contract

              alias_name = resolved_representation_class.root_key.singular.to_sym
              import(association_contract, as: alias_name)

              :"#{alias_name}_nested_payload"
            end

            def resolve_association_representation_class(association)
              IncludesResolver.resolve_representation_class(representation_class, association)
            end

            def sti_base_representation?
              inheritance = representation_class.inheritance
              inheritance&.subclasses&.any? && inheritance.base_class == representation_class
            end

            def primary_key_type
              model = representation_class.model_class
              model.type_for_attribute(model.primary_key).type
            end
          end
        end
      end
    end
  end
end
