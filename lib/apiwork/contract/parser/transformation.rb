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

          return meta unless meta.present? && @schema_class

          meta_key_transform = @schema_class.serialize_key_transform
          Apiwork::Transform::Case.hash(meta, meta_key_transform)
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
            end
          end

          transformed
        end
      end
    end
  end
end
