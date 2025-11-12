# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      # Coercion logic for Parser
      #
      # Handles type coercion before validation:
      # - Converts strings to appropriate types (integer, boolean, date, etc)
      # - Handles nested objects recursively
      # - Handles arrays with typed elements
      # - Handles union types with multiple variants
      # - Handles custom types (like post_filter, boolean_filter)
      #
      module Coercion
        extend ActiveSupport::Concern

        private

        # Coerce data types before validation
        def coerce(data)
          return data unless data.is_a?(Hash)
          return data unless definition

          coerce_hash(data, definition)
        end

        # Recursively coerce hash based on definition
        def coerce_hash(hash, definition)
          coerced = hash.dup

          definition.params.each do |name, param_options|
            next unless coerced.key?(name)

            value = coerced[name]
            coerced[name] = coerce_value(value, param_options)
          end

          coerced
        end

        # Coerce single value based on param options
        def coerce_value(value, param_options)
          type = param_options[:type]

          # Handle union types
          return coerce_union(value, param_options[:union]) if type == :union

          # Handle arrays
          return coerce_array(value, param_options) if type == :array && value.is_a?(Array)

          # Handle shape objects
          return coerce_hash(value, param_options[:shape]) if param_options[:shape] && value.is_a?(Hash)

          # Handle primitive types
          if Coercer.performable?(type)
            coerced = Coercer.perform(value, type)
            return coerced unless coerced.nil?
          end

          value
        end

        # Coerce array elements
        def coerce_array(array, param_options)
          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              # Shape object in array
              coerce_hash(item, param_options[:shape])
            elsif param_options[:of] && Coercer.performable?(param_options[:of])
              # Simple typed array
              coerced = Coercer.perform(item, param_options[:of])
              coerced.nil? ? item : coerced
            elsif param_options[:of] && item.is_a?(Hash)
              # Array of custom type (like array of :filter)
              # Resolve custom type and coerce each element
              custom_type_block = definition.contract_class.resolve_custom_type(param_options[:of], nil)
              if custom_type_block
                custom_def = Definition.new(type: @direction, contract_class: definition.contract_class)
                custom_def.instance_eval(&custom_type_block)
                coerce_hash(item, custom_def)
              else
                item
              end
            else
              item
            end
          end
        end

        # Coerce union - try each variant
        def coerce_union(value, union_def)
          # Special case: boolean unions need coercion for query params
          if union_def.variants.any? { |variant| variant[:type] == :boolean }
            coerced = Coercer.perform(value, :boolean)
            return coerced unless coerced.nil?
          end

          # For custom types and arrays, try coercing with each variant
          union_def.variants.each do |variant|
            variant_type = variant[:type]
            variant_of = variant[:of]

            # Handle array variant (like array of post_filter)
            # If array element is a custom type, resolve and coerce each element
            if variant_type == :array && value.is_a?(Array) && variant_of
              custom_type_block = definition.contract_class.resolve_custom_type(variant_of, :root)
              if custom_type_block
                # Build custom type definition for array elements
                custom_def = Definition.new(type: @direction, contract_class: definition.contract_class)
                custom_def.instance_eval(&custom_type_block)

                # Coerce each element
                coerced_array = value.map do |item|
                  item.is_a?(Hash) ? coerce_hash(item, custom_def) : item
                end
                return coerced_array
              end
            end

            # Handle custom type variant (like post_filter)
            custom_type_block = definition.contract_class.resolve_custom_type(variant_type, :root)
            next unless custom_type_block

            # Build custom type definition
            custom_def = Definition.new(type: @direction, contract_class: definition.contract_class)
            custom_def.instance_eval(&custom_type_block)

            # Try coercing with this custom type
            if value.is_a?(Hash)
              coerced = coerce_hash(value, custom_def)
              return coerced
            end
          end

          # For other unions, return original (validation will determine correct variant)
          value
        end
      end
    end
  end
end
