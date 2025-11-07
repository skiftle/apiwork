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
        # @return [Hash] Serialized variant
        def serialize_variant(variant_def, definition)
          result = {
            type: variant_def[:type]
          }

          result[:of] = variant_def[:of] if variant_def[:of]
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
