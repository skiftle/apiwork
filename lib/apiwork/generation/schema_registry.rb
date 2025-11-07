# frozen_string_literal: true

require 'digest'

module Apiwork
  module Generation
    # SchemaRegistry - Tracks and deduplicates schemas using shape fingerprinting
    #
    # Detects when multiple contract definitions have identical shapes and assigns
    # them to the same component for reuse across the generated schema.
    #
    # @example Finding duplicate nested objects
    #   registry = SchemaRegistry.new
    #
    #   # Both Post and Comment have same author shape
    #   post_author = { type: 'object', shape: { name: {...}, email: {...} } }
    #   comment_author = { type: 'object', shape: { name: {...}, email: {...} } }
    #
    #   registry.register('post_author', post_author) # => 'AuthorInput'
    #   registry.register('comment_author', comment_author) # => 'AuthorInput' (same!)
    class SchemaRegistry
      def initialize
        @fingerprints = {} # fingerprint => component_name
        @schemas = {}      # component_name => schema_definition
      end

      # Register a schema and get its component name
      # If an identical shape exists, returns existing component name
      #
      # @param key [String] Suggested key for this schema (e.g., 'post_author')
      # @param definition [Hash] Contract definition from as_json
      # @return [String] Component name to use
      def register(key, definition)
        fingerprint = calculate_fingerprint(definition)

        # Return existing component if fingerprint matches
        return @fingerprints[fingerprint] if @fingerprints.key?(fingerprint)

        # Create new component
        component_name = generate_component_name(key)
        @fingerprints[fingerprint] = component_name
        @schemas[component_name] = definition

        component_name
      end

      # Get all registered schemas
      #
      # @return [Hash] component_name => schema_definition
      def all_schemas
        @schemas
      end

      # Check if a schema with this fingerprint already exists
      #
      # @param definition [Hash] Contract definition
      # @return [String, nil] Component name if exists
      def find_by_shape(definition)
        fingerprint = calculate_fingerprint(definition)
        @fingerprints[fingerprint]
      end

      private

      # Calculate normalized fingerprint for a schema definition
      # Identical shapes produce identical fingerprints
      #
      # @param definition [Hash] Contract definition
      # @return [String] SHA256 fingerprint
      def calculate_fingerprint(definition)
        normalized = normalize_definition(definition)
        Digest::SHA256.hexdigest(normalized.to_json)
      end

      # Normalize a definition for fingerprinting
      # Removes context-specific details, keeps only structural information
      #
      # @param definition [Hash] Contract definition
      # @return [Hash] Normalized definition
      def normalize_definition(definition)
        case definition[:type]
        when 'object'
          {
            type: 'object',
            required: (definition[:required] || []).sort,
            shape: normalize_shape(definition[:shape])
          }
        when 'array'
          {
            type: 'array',
            of: normalize_definition(definition[:of])
          }
        when 'union'
          variants = definition[:variants] || []
          {
            type: 'union',
            variants: variants.map { |t| normalize_definition(t) }.sort_by(&:to_json)
          }
        when 'enum'
          {
            type: 'enum',
            values: definition[:values].sort
          }
        when 'custom'
          {
            type: 'custom',
            custom_type: definition[:custom_type],
            shape: normalize_shape(definition[:shape])
          }
        else
          # Primitives: string, integer, boolean, etc.
          { type: definition[:type] }
        end
      end

      # Normalize a shape hash (object properties)
      #
      # @param shape [Hash] Property name => definition
      # @return [Hash] Normalized shape with sorted keys
      def normalize_shape(shape)
        return nil unless shape

        shape.transform_values { |v| normalize_definition(v) }
             .sort
             .to_h
      end

      # Generate a component name from a key
      # Converts snake_case to PascalCase
      #
      # @param key [String] Key like 'post_author' or 'create_post_input'
      # @return [String] PascalCase component name like 'PostAuthor'
      def generate_component_name(key)
        key.to_s.split('_').map(&:capitalize).join
      end
    end
  end
end
