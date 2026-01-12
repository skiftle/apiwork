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
              params[name] = param_options[:store] if param_options[:store] && params.key?(name)

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
            variant = union_definition.variants.find do |variant|
              variant[:tag].to_s == tag.to_s
            end
            return unless variant

            variant_type = variant[:type]
            apply_sti_transform_to_custom_type(value, variant_type, parent_definition)
          end

          def apply_sti_transform_to_custom_type(value, type_name, parent_definition)
            contract_class = parent_definition&.contract_class
            return unless contract_class

            type_definition = contract_class.resolve_custom_type(type_name)

            if type_definition
              temp_param = Object.new(
                contract_class,
                action_name: parent_definition.action_name,
              )
              temp_param.copy_type_definition_params(type_definition, temp_param)
              apply_sti_discriminator_transform(value, temp_param)
            else
              apply_sti_transform_to_registered_union(value, type_name, parent_definition)
            end
          end

          def apply_sti_transform_to_registered_union(value, type_name, parent_definition)
            contract_class = parent_definition&.contract_class
            api_class = contract_class.api_class
            return unless api_class

            scoped_name = api_class.scoped_type_name(contract_class, type_name)
            union_definition = api_class.type_registry[scoped_name] || api_class.type_registry[type_name]
            return unless union_definition

            payload = union_definition.payload
            return unless payload && payload[:type] == :union

            discriminator = payload[:discriminator]
            return unless discriminator && value.key?(discriminator)

            tag = value[discriminator]
            variant = payload[:variants]&.find { |v| v[:tag].to_s == tag.to_s }
            return unless variant

            apply_sti_transform_to_custom_type(value, variant[:type], parent_definition)
          end

          def transform_custom_type_array(value, param_definition, definition)
            shape = resolve_custom_type_shape(param_definition[:of], definition)
            return value.map { |item| item.is_a?(Hash) ? apply(item, shape) : item } if shape

            nil
          end

          def resolve_custom_type_shape(type_name, definition)
            contract_class = definition&.contract_class
            return nil unless contract_class

            type_definition = contract_class.resolve_custom_type(type_name)
            return nil unless type_definition

            if type_definition.object?
              temp_param = Object.new(
                contract_class,
                action_name: definition.action_name,
              )
              temp_param.copy_type_definition_params(type_definition, temp_param)
              temp_param
            elsif type_definition.union?
              first_variant = type_definition.variants.first
              return nil unless first_variant

              variant_type_definition = contract_class.resolve_custom_type(first_variant[:type])
              return nil unless variant_type_definition&.object?

              temp_param = Object.new(
                contract_class,
                action_name: definition.action_name,
              )
              temp_param.copy_type_definition_params(variant_type_definition, temp_param)
              temp_param
            end
          end
        end
      end
    end
  end
end
