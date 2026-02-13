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

                payload_type_name = [action_name, 'payload'].join('_').to_sym
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
              type_name = [action_name, 'payload'].join('_').to_sym
              return if type?(type_name)

              object(type_name, description: representation_class.description) do |object|
                if representation_class.subclass?
                  parent_inheritance = representation_class.superclass.inheritance

                  object.literal(
                    parent_inheritance.column,
                    optional: action_name == :update,
                    value: representation_class.sti_name,
                  )
                end

                collect_writable_params(action_name).each do |param_config|
                  object.param(param_config[:name], **param_config[:options])
                end
              end
            end

            def build_nested_payload_union
              build_nested_payload(:create)
              build_nested_payload(:update)
              build_nested_payload(:delete)
              build_nested_union
            end

            def build_nested_payload(action_name)
              type_name = [:nested, action_name, :payload].join('_').to_sym
              return if type?(type_name)

              writable = action_name != :delete

              object(type_name) do |object|
                object.literal(Constants::OP, optional: true, value: action_name.to_s)
                object.param(:id, optional: writable, type: primary_key_type)

                next unless writable

                collect_writable_params(action_name).each do |param_config|
                  object.param(param_config[:name], **param_config[:options])
                end
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
                subclass_contract = contract_for(subclass)
                next unless subclass_contract

                alias_name = subclass.root_key.singular.to_sym
                import(subclass_contract, as: alias_name)

                { tag: subclass.sti_name, type: [alias_name, action_name, 'payload'].join('_').to_sym }
              end

              union([action_name, 'payload'].join('_').to_sym, discriminator: representation_inheritance.column) do |union|
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
                deprecated: attribute.deprecated?,
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

              allowed_values = association.polymorphic.map(&:polymorphic_name)

              { enum: allowed_values }
            end

            def association_options(association)
              payload_type = resolve_association_payload_type(association)

              options = {
                as: [association.name, 'attributes'].join('_').to_sym,
                deprecated: association.deprecated?,
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

              representation_class = association.representation_class
              return nil unless representation_class

              association_contract = contract_for(representation_class)
              return nil unless association_contract

              alias_name = representation_class.root_key.singular.to_sym
              import(association_contract, as: alias_name)

              [alias_name, 'nested_payload'].join('_').to_sym
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
