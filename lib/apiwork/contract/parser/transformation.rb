# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      module Transformation
        extend ActiveSupport::Concern

        def transform_meta_keys(meta)
          raise ArgumentError, 'transform_meta_keys only available for response_body direction' unless @direction == :response_body

          return meta if meta.blank? || @schema_class.nil?

          case @schema_class.output_key_format
          when :camel
            meta.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          when :underscore
            meta.deep_transform_keys { |key| key.to_s.underscore.to_sym }
          else
            meta
          end
        end

        private

        def transform(data)
          return data unless definition

          case @direction
          when :query, :body
            apply_transformations(data, definition)
          when :response_body
            data
          end
        end

        def apply_transformations(params, definition)
          return params unless params.is_a?(Hash)
          return params unless definition

          transformed = params.dup

          definition.params.each do |name, param_definition|
            next unless transformed.key?(name)

            value = transformed[name]

            if param_definition[:as]
              transformed[param_definition[:as]] = transformed.delete(name)
              name = param_definition[:as] # Update name for nested processing
              value = transformed[name]
            end

            if param_definition[:shape] && value.is_a?(Hash)
              transformed[name] = apply_transformations(value, param_definition[:shape])
            elsif param_definition[:shape] && value.is_a?(Array)
              transformed[name] = value.map do |item|
                item.is_a?(Hash) ? apply_transformations(item, param_definition[:shape]) : item
              end
            elsif param_definition[:type] == :array && param_definition[:of] && value.is_a?(Array)
              transformed_array = transform_custom_type_array(value, param_definition, definition)
              transformed[name] = transformed_array if transformed_array
            end
          end

          transformed
        end

        def transform_custom_type_array(value, param_definition, definition)
          shape = resolve_custom_type_shape(param_definition[:of], definition, param_definition[:type_contract_class])

          return value.map { |item| item.is_a?(Hash) ? apply_transformations(item, shape) : item } if shape

          transform_union_type_array(value, param_definition, definition)
        end

        def transform_union_type_array(value, param_definition, definition)
          return nil unless param_definition[:type_contract_class]

          action_name = definition.action_name || :create
          nested_request_def = param_definition[:type_contract_class].action_definition(action_name)&.request_definition
          nested_definition = nested_request_def&.body_definition

          return nil unless nested_definition

          root_param = nested_definition.params.values.first
          nested_shape = root_param[:shape] if root_param

          return nil unless nested_shape

          value.map { |item| item.is_a?(Hash) ? apply_transformations(item, nested_shape) : item }
        end

        def resolve_custom_type_shape(type_name, definition, type_contract_class = nil)
          contract_class = type_contract_class || definition&.contract_class
          return nil unless contract_class

          custom_type_block = contract_class.resolve_custom_type(type_name)
          return nil unless custom_type_block

          temp_definition = Apiwork::Contract::Definition.new(
            type: definition.type,
            contract_class: contract_class,
            action_name: definition.action_name
          )

          temp_definition.instance_eval(&custom_type_block)

          temp_definition
        end
      end
    end
  end
end
