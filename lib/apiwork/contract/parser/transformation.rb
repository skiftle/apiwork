# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      # Transformation logic for Parser
      #
      # Handles data transformation after validation:
      # - Applies 'as:' parameter renaming (e.g., comments → comments_attributes)
      # - Transforms meta keys to match schema's key transform
      # - Handles nested transformations recursively
      #
      module Transformation
        extend ActiveSupport::Concern

        def transform_meta_keys(meta)
          raise ArgumentError, 'transform_meta_keys only available for output direction' unless @direction == :output

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

        # Transform data based on direction
        def transform(data)
          return data unless definition

          case @direction
          when :input
            apply_transformations(data, definition)
          when :output
            # For now, no transformations on output
            # Infrastructure ready if we add 'as:' support to output definitions
            data
          end
        end

        # Recursively apply 'as:' transformations from definition
        # Used for input direction to transform params (e.g., comments → comments_attributes)
        def apply_transformations(params, definition)
          return params unless params.is_a?(Hash)
          return params unless definition

          transformed = params.dup

          definition.params.each do |name, param_def|
            next unless transformed.key?(name)

            value = transformed[name]

            # If param has 'as:', rename the key
            if param_def[:as]
              transformed[param_def[:as]] = transformed.delete(name)
              name = param_def[:as] # Update name for nested processing
              value = transformed[name]
            end

            # Recursively transform shape params
            if param_def[:shape] && value.is_a?(Hash)
              transformed[name] = apply_transformations(value, param_def[:shape])
            elsif param_def[:shape] && value.is_a?(Array)
              # For arrays, transform each element
              transformed[name] = value.map do |item|
                item.is_a?(Hash) ? apply_transformations(item, param_def[:shape]) : item
              end
            elsif param_def[:type] == :array && param_def[:of] && value.is_a?(Array)
              # Handle arrays with custom types (of: :custom_type)
              transformed_array = transform_custom_type_array(value, param_def, definition)
              transformed[name] = transformed_array if transformed_array
            end
          end

          transformed
        end

        # Transform array of custom types (regular types or union types)
        def transform_custom_type_array(value, param_def, definition)
          # Try to resolve as regular custom type
          shape = resolve_custom_type_shape(param_def[:of], definition, param_def[:type_contract_class])

          return value.map { |item| item.is_a?(Hash) ? apply_transformations(item, shape) : item } if shape

          # Try union type (nested_payload) transformation
          transform_union_type_array(value, param_def, definition)
        end

        # Transform array of union types (nested_payload)
        def transform_union_type_array(value, param_def, definition)
          return nil unless param_def[:type_contract_class]

          nested_contract = param_def[:type_contract_class]
          action_name = definition.action_name || :create
          nested_definition = nested_contract.action_definition(action_name)&.input_definition

          return nil unless nested_definition

          # The input definition has a root key wrapper (e.g., {comment: {...}})
          # Get the shape definition inside the root key for transformation
          root_param = nested_definition.params.values.first
          nested_shape = root_param[:shape] if root_param

          return nil unless nested_shape

          value.map { |item| item.is_a?(Hash) ? apply_transformations(item, nested_shape) : item }
        end

        # Resolve a custom type to its shape definition for transformation
        # This allows recursive transformation of arrays with custom types (of: :custom_type)
        def resolve_custom_type_shape(type_name, definition, type_contract_class = nil)
          # Use type_contract_class if provided, otherwise fall back to definition.contract_class
          contract_class = type_contract_class || definition&.contract_class
          return nil unless contract_class

          # Try to resolve the custom type from the contract
          custom_type_block = contract_class.resolve_custom_type(type_name)
          return nil unless custom_type_block

          # Create a temporary definition and expand the custom type
          temp_definition = Apiwork::Contract::Definition.new(
            type: definition.type,
            contract_class: contract_class,
            action_name: definition.action_name
          )

          # Expand the custom type to get its shape
          temp_definition.instance_eval(&custom_type_block)

          temp_definition
        end
      end
    end
  end
end
