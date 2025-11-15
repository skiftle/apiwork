# frozen_string_literal: true

module Apiwork
  module Contract
    # Serialization module for converting Contract definitions to JSON
    # Used for debugging auto-generated contracts and route introspection
    module Serialization
      class << self
        def serialize_definition(definition, visited: Set.new)
          return nil unless definition

          # Check if this is an unwrapped union (special case for response outputs)
          return serialize_unwrapped_union(definition, visited: visited) if definition.instance_variable_get(:@unwrapped_union)

          result = {}

          definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            result[name] = serialize_param(name, param_options, definition, visited: visited)
          end

          result
        end

        def serialize_unwrapped_union(definition, visited: Set.new)
          discriminator = definition.instance_variable_get(:@unwrapped_union_discriminator)

          # Separate params into success and error variants based on typical patterns
          success_params = {}
          error_params = {}

          definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            case name
            when :ok
              # ok field with literal values in each variant
              next # We'll add this manually to each variant
            when :errors
              # errors is only in error variant
              # Errors should always be required in error responses
              error_params[name] = serialize_param(name, param_options, definition, visited: visited).tap do |serialized|
                serialized[:required] = true
              end
            else
              # All other fields are in success variant
              serialized = serialize_param(name, param_options, definition, visited: visited)
              # Resource fields should be required in success variant (but not meta)
              serialized[:required] = true unless name == :meta
              success_params[name] = serialized
            end
          end

          # Build union structure
          {
            type: :union,
            discriminator: discriminator,
            variants: [
              {
                tag: true,
                type: :object,
                shape: {
                  ok: { type: :literal, value: true, required: true },
                  **success_params
                }
              },
              {
                tag: false,
                type: :object,
                shape: {
                  ok: { type: :literal, value: false, required: true },
                  **error_params
                }
              }
            ]
          }
        end

        def serialize_param(_name, options, definition, visited: Set.new)
          # Handle union types
          if options[:type] == :union
            result = serialize_union(options[:union], definition, visited: visited)
            result[:required] = options[:required] || false
            result[:nullable] = options[:nullable] || false
            return result
          end

          # Handle custom types - return type reference instead of expanding
          if options[:custom_type]
            # Qualify custom type name (only for contracts with schema_class)
            custom_type_name = options[:custom_type]
            if definition.contract_class.respond_to?(:schema_class) &&
               definition.contract_class.schema_class &&
               definition.contract_class.resolve_custom_type(custom_type_name)
              # Determine scope for qualification
              scope = determine_scope_for_type(definition, custom_type_name)
              custom_type_name = Descriptor::Registry.qualified_name(scope, custom_type_name)
            end

            result = {
              type: custom_type_name,
              required: options[:required] || false,
              nullable: options[:nullable] || false
            }
            result[:as] = options[:as] if options[:as]
            return result
          end

          # Qualify custom type names in 'type' parameter (only for contracts with schema_class)
          type_value = options[:type]
          if type_value &&
             definition.contract_class.respond_to?(:schema_class) &&
             definition.contract_class.schema_class &&
             definition.contract_class.resolve_custom_type(type_value)
            # Custom type - use qualified name
            # Determine scope for qualification
            scope = determine_scope_for_type(definition, type_value)
            type_value = Descriptor::Registry.qualified_name(scope, type_value)
          end

          result = {
            type: type_value,
            required: options[:required] || false,
            nullable: options[:nullable] || false
          }

          # Add literal value for literal types
          result[:value] = options[:value] if options[:type] == :literal

          # Add optional metadata (only if meaningfully set)
          result[:default] = options[:default] if options.key?(:default) && !options[:default].nil?

          # Handle enum - differentiate between reference (hash with :ref) and inline (array)
          if options[:enum]
            if options[:enum].is_a?(Hash) && options[:enum][:ref]
              # Enum reference - output the qualified reference symbol for code generators
              # Use qualified name with correct scope for hierarchical naming
              scope = determine_scope_for_enum(definition, options[:enum][:ref])
              qualified_enum_name = Descriptor::EnumStore.qualified_name(scope, options[:enum][:ref])
              result[:enum] = qualified_enum_name
            else
              # Inline enum - output the values array
              result[:enum] = options[:enum]
            end
          end

          result[:as] = options[:as] if options[:as]

          # Handle 'of' parameter - qualify custom types (only for contracts with schema_class)
          if options[:of]
            # Check if it's a custom type that needs qualification
            if definition.contract_class.respond_to?(:schema_class) &&
               definition.contract_class.schema_class &&
               definition.contract_class.resolve_custom_type(options[:of])
              # Custom type - use qualified name (e.g., service_filter instead of filter)
              scope = determine_scope_for_type(definition, options[:of])
              result[:of] = Descriptor::Registry.qualified_name(scope, options[:of])
            else
              # Primitive type or global type - keep as-is
              result[:of] = options[:of]
            end
          end

          # Handle shape (nested objects) - only for non-custom types
          result[:shape] = serialize_definition(options[:shape], visited: visited) if options[:shape]

          result
        end

        def serialize_union(union_def, definition, visited: Set.new)
          result = {
            type: :union,
            variants: union_def.variants.map { |variant| serialize_variant(variant, definition, visited: visited) }
          }
          result[:discriminator] = union_def.discriminator if union_def.discriminator
          result
        end

        def serialize_variant(variant_def, parent_definition, visited: Set.new)
          variant_type = variant_def[:type]

          # Check if variant type is a custom type - if so, just return a reference
          custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_type)
          if custom_type_block
            # Return type reference (qualified only for schema-based contracts)
            # The type definition will be in the types hash at API level
            if parent_definition.contract_class.respond_to?(:schema_class) &&
               parent_definition.contract_class.schema_class
              scope = determine_scope_for_type(parent_definition, variant_type)
              qualified_type_name = Descriptor::Registry.qualified_name(scope, variant_type)
              result = { type: qualified_type_name }
            else
              result = { type: variant_type }
            end
            result[:tag] = variant_def[:tag] if variant_def[:tag]
            return result
          end

          result = { type: variant_type }

          # Add tag for discriminated unions
          result[:tag] = variant_def[:tag] if variant_def[:tag]

          # Handle 'of' - qualify custom types but don't expand them (only for contracts with schema_class)
          if variant_def[:of]
            # Check if it's a custom type that needs qualification
            if parent_definition.contract_class.respond_to?(:schema_class) &&
               parent_definition.contract_class.schema_class &&
               parent_definition.contract_class.resolve_custom_type(variant_def[:of])
              # Custom type - use qualified name (e.g., service_filter instead of filter)
              scope = determine_scope_for_type(parent_definition, variant_def[:of])
              result[:of] = Descriptor::Registry.qualified_name(scope, variant_def[:of])
            else
              # Primitive type or global type - keep as-is
              result[:of] = variant_def[:of]
            end
          end

          # Handle enum - qualify if it's a reference (only for contracts with schema_class)
          if variant_def[:enum]
            if variant_def[:enum].is_a?(Symbol)
              # Enum reference - use qualified name with correct scope for hierarchical naming
              if parent_definition.contract_class.respond_to?(:schema_class) &&
                 parent_definition.contract_class.schema_class
                scope = determine_scope_for_enum(parent_definition, variant_def[:enum])
                result[:enum] = Descriptor::EnumStore.qualified_name(scope, variant_def[:enum])
              else
                result[:enum] = variant_def[:enum]
              end
            else
              # Inline enum array - keep as-is
              result[:enum] = variant_def[:enum]
            end
          end

          # Handle shape in variant (for object or array of object)
          result[:shape] = serialize_definition(variant_def[:shape], visited: visited) if variant_def[:shape]

          result
        end

        def determine_scope_for_type(definition, type_name)
          definition.contract_class
        end

        def determine_scope_for_enum(definition, enum_name)
          definition.contract_class
        end
      end
    end
  end
end
