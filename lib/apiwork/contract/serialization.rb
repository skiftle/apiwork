# frozen_string_literal: true

require 'set'

module Apiwork
  module Contract
    # Serialization module for converting Contract definitions to JSON
    # Used for debugging auto-generated contracts and route introspection
    module Serialization
      class << self
        # Serialize a Definition to a hash representation
        # @param definition [Definition] The definition to serialize
        # @param visited [Set] Set of custom type names currently being serialized (for circular reference protection)
        # @return [Hash] Hash representation with params and their metadata
        def serialize_definition(definition, visited: Set.new)
          return nil unless definition

          result = {}

          definition.params.each do |name, param_options|
            result[name] = serialize_param(name, param_options, definition, visited: visited)
          end

          result
        end

        # Serialize a single parameter with all its metadata
        # @param name [Symbol] Parameter name
        # @param options [Hash] Parameter options from definition
        # @param definition [Definition] Parent definition (for custom type resolution)
        # @param visited [Set] Set of custom type names currently being serialized (for circular reference protection)
        # @return [Hash] Serialized parameter with type, required, shape, etc.
        def serialize_param(name, options, definition, visited: Set.new)
          # Handle union types
          if options[:type] == :union
            return serialize_union(options[:union], definition, visited: visited)
          end

          result = {
            type: options[:type],
            required: options[:required] || false
          }

          # Add literal value for literal types
          result[:value] = options[:value] if options[:type] == :literal

          # Add optional metadata (only if meaningfully set)
          result[:default] = options[:default] if options.key?(:default) && !options[:default].nil?

          # Handle enum - differentiate between reference (hash with :ref) and inline (array)
          if options[:enum]
            if options[:enum].is_a?(Hash) && options[:enum][:ref]
              # Enum reference - output the reference symbol for code generators
              result[:enum] = options[:enum][:ref]
            else
              # Inline enum - output the values array
              result[:enum] = options[:enum]
            end
          end

          result[:as] = options[:as] if options[:as]
          result[:of] = options[:of] if options[:of]
          result[:nullable] = options[:nullable] if options[:nullable]

          # Handle custom types
          if options[:custom_type]
            result[:custom_type] = options[:custom_type]
          end

          # Handle shape (nested objects)
          if options[:shape]
            result[:shape] = serialize_definition(options[:shape], visited: visited)
          end

          result
        end

        # Serialize a union type
        # @param union_def [UnionDefinition] The union definition
        # @param definition [Definition] Parent definition (for custom type resolution)
        # @param visited [Set] Set of custom type names currently being serialized (for circular reference protection)
        # @return [Hash] Union representation with variants
        def serialize_union(union_def, definition, visited: Set.new)
          result = {
            type: :union,
            variants: union_def.variants.map { |variant| serialize_variant(variant, definition, visited: visited) }
          }
          result[:discriminator] = union_def.discriminator if union_def.discriminator
          result
        end

        # Serialize a single union variant
        # @param variant_def [Hash] Variant definition hash
        # @param definition [Definition] Parent definition (for custom type resolution)
        # @param visited [Set] Set of custom type names currently being serialized (for circular reference protection)
        # @return [Hash] Serialized variant with type references (not expanded)
        def serialize_variant(variant_def, parent_definition, visited: Set.new)
          variant_type = variant_def[:type]

          # Check if variant type is a custom type - if so, just return a reference
          custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_type, parent_definition.type_scope)
          if custom_type_block
            # Return type reference instead of expanding
            # The type definition will be in the types hash at API level
            result = { type: variant_type }
            result[:tag] = variant_def[:tag] if variant_def[:tag]
            return result
          end

          result = { type: variant_type }

          # Add tag for discriminated unions
          result[:tag] = variant_def[:tag] if variant_def[:tag]

          # Handle 'of' - just pass through, don't expand custom types
          if variant_def[:of]
            result[:of] = variant_def[:of]
            # Custom types in 'of' will be resolved from types hash, no expansion needed
          end

          result[:enum] = variant_def[:enum] if variant_def[:enum]

          # Handle shape in variant (for object or array of object)
          if variant_def[:shape]
            result[:shape] = serialize_definition(variant_def[:shape], visited: visited)
          end

          result
        end
      end
    end
  end
end
