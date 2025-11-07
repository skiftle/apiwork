# frozen_string_literal: true

module Apiwork
  module Contract
    # Serialization module for converting Contract definitions to JSON
    # Used for debugging auto-generated contracts and route introspection
    module Serialization
      class << self
        # Serialize a Definition to a hash representation
        # @param definition [Definition] The definition to serialize
        # @return [Hash] Hash representation with params and their metadata
        def serialize_definition(definition)
          return nil unless definition

          result = {}

          definition.params.each do |name, param_options|
            result[name] = serialize_param(name, param_options, definition)
          end

          result
        end

        # Serialize a single parameter with all its metadata
        # @param name [Symbol] Parameter name
        # @param options [Hash] Parameter options from definition
        # @param definition [Definition] Parent definition (for custom type resolution)
        # @return [Hash] Serialized parameter with type, required, shape, etc.
        def serialize_param(name, options, definition)
          # Handle union types
          if options[:type] == :union
            return serialize_union(options[:union], definition)
          end

          result = {
            type: options[:type],
            required: options[:required] || false
          }

          # Add optional metadata (only if meaningfully set)
          result[:default] = options[:default] if options.key?(:default) && !options[:default].nil?
          result[:enum] = options[:enum] if options[:enum]
          result[:as] = options[:as] if options[:as]
          result[:of] = options[:of] if options[:of]
          result[:nullable] = options[:nullable] if options[:nullable]

          # Handle custom types
          if options[:custom_type]
            result[:custom_type] = options[:custom_type]
          end

          # Handle shape (nested objects)
          if options[:shape]
            result[:shape] = serialize_definition(options[:shape])
          end

          result
        end

        # Serialize a union type
        # @param union_def [UnionDefinition] The union definition
        # @param definition [Definition] Parent definition (for custom type resolution)
        # @return [Hash] Union representation with variants
        def serialize_union(union_def, definition)
          {
            type: :union,
            variants: union_def.variants.map { |variant| serialize_variant(variant, definition) }
          }
        end

        # Serialize a single union variant
        # @param variant_def [Hash] Variant definition hash
        # @param definition [Definition] Parent definition (for custom type resolution)
        # @return [Hash] Serialized variant with expanded custom types
        def serialize_variant(variant_def, parent_definition)
          variant_type = variant_def[:type]

          # Check if variant type is a custom type and resolve it
          custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_type, parent_definition.type_scope)
          if custom_type_block
            # Expand custom type to show its structure
            # Note: Use instance_variable_get because Definition has both attr_reader :type and def type() method
            direction = parent_definition.instance_variable_get(:@type)
            contract_class = parent_definition.contract_class
            scope = parent_definition.type_scope

            custom_def = Definition.new(direction, contract_class, type_scope: scope)
            custom_def.instance_eval(&custom_type_block)

            return {
              type: :object,
              custom_type: variant_type,
              shape: serialize_definition(custom_def)
            }
          end

          result = { type: variant_type }

          # Handle 'of' - check if it's a custom type
          if variant_def[:of]
            result[:of] = variant_def[:of]

            # If 'of' is a custom type, expand it too
            of_custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_def[:of], parent_definition.type_scope)
            if of_custom_type_block
              # Note: Use instance_variable_get because Definition has both attr_reader :type and def type() method
              direction = parent_definition.instance_variable_get(:@type)
              contract_class = parent_definition.contract_class
              scope = parent_definition.type_scope

              of_custom_def = Definition.new(direction, contract_class, type_scope: scope)
              of_custom_def.instance_eval(&of_custom_type_block)
              result[:of_shape] = serialize_definition(of_custom_def)
            end
          end

          result[:enum] = variant_def[:enum] if variant_def[:enum]

          # Handle shape in variant (for object or array of object)
          if variant_def[:shape]
            result[:shape] = serialize_definition(variant_def[:shape])
          end

          result
        end
      end
    end
  end
end
