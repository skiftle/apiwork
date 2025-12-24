# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Transformation
        class << self
          def apply(params, definition)
            return params unless params.is_a?(Hash)

            transformed = params.dup

            definition.params.each do |name, param_definition|
              next unless transformed.key?(name)

              value = transformed[name]

              if param_definition[:as]
                transformed[param_definition[:as]] = transformed.delete(name)
                name = param_definition[:as]
                value = transformed[name]
              end

              if param_definition[:shape] && value.is_a?(Hash)
                transformed[name] = apply(value, param_definition[:shape])
              elsif param_definition[:shape] && value.is_a?(Array)
                transformed[name] = value.map do |item|
                  item.is_a?(Hash) ? apply(item, param_definition[:shape]) : item
                end
              elsif param_definition[:type] == :array && param_definition[:of] && value.is_a?(Array)
                transformed_array = transform_custom_type_array(value, param_definition, definition)
                transformed[name] = transformed_array if transformed_array
              end
            end

            apply_sti_discriminator_transform(transformed, definition)

            transformed
          end

          private

          def apply_sti_discriminator_transform(params, definition)
            definition.params.each do |name, param_options|
              # Handle direct sti_mapping on param
              if param_options[:sti_mapping] && params.key?(name)
                mapping = param_options[:sti_mapping]
                tag = params[name]
                params[name] = mapping[tag.to_sym] if mapping.key?(tag.to_sym)
              end

              # Recurse into nested structures (shapes, custom types, unions)
              value = params[name]
              next unless value.is_a?(Hash)

              if param_options[:shape]
                apply_sti_discriminator_transform(value, param_options[:shape])
              elsif param_options[:union]
                apply_sti_transform_to_union_value(value, param_options[:union], definition)
              elsif param_options[:type].is_a?(Symbol)
                apply_sti_transform_to_custom_type(value, param_options[:type], definition)
              end
            end
          end

          def apply_sti_transform_to_union_value(value, union_definition, parent_definition)
            discriminator = union_definition.discriminator
            return unless discriminator && value.key?(discriminator)

            tag = value[discriminator]
            variant = union_definition.variants.find do |v|
              v[:tag].to_s == tag.to_s
            end
            return unless variant

            variant_type = variant[:type]
            apply_sti_transform_to_custom_type(value, variant_type, parent_definition)
          end

          def apply_sti_transform_to_custom_type(value, type_name, parent_definition)
            contract_class = parent_definition&.contract_class
            return unless contract_class

            custom_type_blocks = contract_class.resolve_custom_type(type_name)

            if custom_type_blocks
              temp_param_definition = Apiwork::Contract::ParamDefinition.new(
                contract_class,
                action_name: parent_definition.action_name
              )
              custom_type_blocks.each { |block| temp_param_definition.instance_eval(&block) }
              apply_sti_discriminator_transform(value, temp_param_definition)
            else
              # Check if this is a union type registered at API level
              apply_sti_transform_to_registered_union(value, type_name, parent_definition)
            end
          end

          def apply_sti_transform_to_registered_union(value, type_name, parent_definition)
            contract_class = parent_definition&.contract_class
            api_class = contract_class&.api_class
            return unless api_class

            scoped_name = api_class.scoped_name(contract_class, type_name)
            union_metadata = api_class.type_system.types[scoped_name] || api_class.type_system.types[type_name]
            return unless union_metadata

            payload = union_metadata[:payload]
            return unless payload && payload[:type] == :union

            discriminator = payload[:discriminator]
            return unless discriminator && value.key?(discriminator)

            tag = value[discriminator]
            variant = payload[:variants]&.find { |v| v[:tag].to_s == tag.to_s }
            return unless variant

            # Apply transform to the variant type
            apply_sti_transform_to_custom_type(value, variant[:type], parent_definition)
          end

          def transform_custom_type_array(value, param_definition, definition)
            shape = resolve_custom_type_shape(param_definition[:of], definition, param_definition[:type_contract_class])

            return value.map { |item| item.is_a?(Hash) ? apply(item, shape) : item } if shape

            transform_union_type_array(value, param_definition, definition)
          end

          def transform_union_type_array(value, param_definition, definition)
            return nil unless param_definition[:type_contract_class]

            action_name = definition.action_name || :create
            nested_request_definition = param_definition[:type_contract_class].action_definition(action_name)&.request_definition
            nested_definition = nested_request_definition&.body_param_definition

            return nil unless nested_definition

            root_param = nested_definition.params.values.first
            nested_shape = root_param[:shape] if root_param

            return nil unless nested_shape

            value.map { |item| item.is_a?(Hash) ? apply(item, nested_shape) : item }
          end

          def resolve_custom_type_shape(type_name, definition, type_contract_class = nil)
            contract_class = type_contract_class || definition&.contract_class
            return nil unless contract_class

            custom_type_block = contract_class.resolve_custom_type(type_name)
            return nil unless custom_type_block

            temp_param_definition = Apiwork::Contract::ParamDefinition.new(
              contract_class,
              action_name: definition.action_name
            )

            custom_type_block.each { |block| temp_param_definition.instance_eval(&block) }

            temp_param_definition
          end
        end
      end
    end
  end
end
