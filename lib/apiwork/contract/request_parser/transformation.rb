# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Transformation
        class << self
          def apply(params, shape)
            return params unless params.is_a?(Hash)

            transformed = params.dup

            shape.params.each do |name, param_options|
              next unless transformed.key?(name)

              value = transformed[name]

              if param_options[:as]
                transformed[param_options[:as]] = transformed.delete(name)
                name = param_options[:as]
                value = transformed[name]
              end

              if param_options[:shape] && value.is_a?(Hash)
                transformed[name] = apply(value, param_options[:shape])
              elsif param_options[:shape] && value.is_a?(Array)
                transformed[name] = value.map do |item|
                  item.is_a?(Hash) ? apply(item, param_options[:shape]) : item
                end
              elsif param_options[:type] == :array && param_options[:of] && value.is_a?(Array)
                transformed_array = transform_custom_type_array(value, param_options, shape)
                transformed[name] = transformed_array if transformed_array
              end
            end

            apply_sti_discriminator_transform(transformed, shape)

            transformed
          end

          private

          def apply_sti_discriminator_transform(params, shape)
            shape.params.each do |name, param_options|
              params[name] = param_options[:store] if param_options[:store] && params.key?(name)

              value = params[name]
              next unless value.is_a?(Hash)

              if param_options[:shape]
                apply_sti_discriminator_transform(value, param_options[:shape])
              elsif param_options[:union]
                apply_sti_transform_to_union_value(value, param_options[:union], shape)
              elsif param_options[:type].is_a?(Symbol)
                apply_sti_transform_to_custom_type(value, param_options[:type], shape)
              end
            end
          end

          def apply_sti_transform_to_union_value(value, union, parent_shape)
            discriminator = union.discriminator
            return unless discriminator && value.key?(discriminator)

            tag = value[discriminator]
            variant = union.variants.find do |variant|
              variant[:tag].to_s == tag.to_s
            end
            return unless variant

            variant_type = variant[:type]
            apply_sti_transform_to_custom_type(value, variant_type, parent_shape)
          end

          def apply_sti_transform_to_custom_type(value, type_name, parent_shape)
            contract_class = parent_shape&.contract_class
            return unless contract_class

            type_definition = contract_class.resolve_custom_type(type_name)

            if type_definition
              temp_param = Object.new(
                contract_class,
                action_name: parent_shape.action_name,
              )
              temp_param.copy_type_definition_params(type_definition, temp_param)
              apply_sti_discriminator_transform(value, temp_param)
            else
              apply_sti_transform_to_registered_union(value, type_name, parent_shape)
            end
          end

          def apply_sti_transform_to_registered_union(value, type_name, parent_shape)
            contract_class = parent_shape&.contract_class
            api_class = contract_class.api_class
            return unless api_class

            scoped_name = api_class.scoped_type_name(contract_class, type_name)
            type_definition = api_class.type_registry[scoped_name] || api_class.type_registry[type_name]
            return unless type_definition

            payload = type_definition.payload
            return unless payload && payload[:type] == :union

            discriminator = payload[:discriminator]
            return unless discriminator && value.key?(discriminator)

            tag = value[discriminator]
            variant = payload[:variants]&.find { |variant| variant[:tag].to_s == tag.to_s }
            return unless variant

            apply_sti_transform_to_custom_type(value, variant[:type], parent_shape)
          end

          def transform_custom_type_array(value, param_options, shape)
            resolved_shape = resolve_custom_type_shape(param_options[:of], shape)
            return value.map { |item| item.is_a?(Hash) ? apply(item, resolved_shape) : item } if resolved_shape

            nil
          end

          def resolve_custom_type_shape(type_name, shape)
            contract_class = shape&.contract_class
            return nil unless contract_class

            type_definition = contract_class.resolve_custom_type(type_name)
            return nil unless type_definition

            scope_contract_class = type_definition.scope || contract_class

            if type_definition.object?
              temp_param = Object.new(
                scope_contract_class,
                action_name: shape.action_name,
              )
              temp_param.copy_type_definition_params(type_definition, temp_param)
              temp_param
            elsif type_definition.union?
              first_variant = type_definition.variants.first
              return nil unless first_variant

              variant_type_definition = scope_contract_class.resolve_custom_type(first_variant[:type])
              return nil unless variant_type_definition&.object?

              variant_contract_class = variant_type_definition.scope || scope_contract_class

              temp_param = Object.new(
                variant_contract_class,
                action_name: shape.action_name,
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
