# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps parameter/field definitions.
    #
    # Used for request params, response bodies, type shapes, and more.
    # Provides type-safe accessors with built-in defaults.
    #
    # @example Basic usage
    #   param.type         # => :string
    #   param.nullable?    # => false
    #   param.optional?    # => true
    #   param.description  # => "User email address"
    #
    # @example Array type
    #   param.array?       # => true
    #   param.of           # => Param for element type
    #
    # @example Object type
    #   param.object?      # => true
    #   param.shape[:name] # => Param for the name field
    class Param
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [Symbol, nil] type (:string, :integer, :array, :object, :union, etc.)
      def type
        @dump[:type]
      end

      # @api public
      # @return [Boolean] whether this is an array type
      def array?
        type == :array
      end

      # @api public
      # @return [Boolean] whether this is an object type
      def object?
        type == :object
      end

      # @api public
      # @return [Boolean] whether this is a union type
      def union?
        type == :union
      end

      # @api public
      # @return [Boolean] whether this is a literal type
      def literal?
        type == :literal
      end

      # @api public
      # @return [Param, nil] element type for arrays
      def of
        return @of if defined?(@of)

        raw = @dump[:of]
        @of = case raw
              when Hash then Param.new(raw)
              when Symbol then Param.new(type: raw)
              end
      end

      # @api public
      # @return [Hash{Symbol => Param}] nested fields for objects
      def shape
        @shape ||= (@dump[:shape] || {}).transform_values { |d| Param.new(d) }
      end

      # @api public
      # @return [Array<Param>] variants for unions
      def variants
        @variants ||= (@dump[:variants] || []).map { |v| Param.new(v) }
      end

      # @api public
      # @return [Symbol, nil] discriminator field for discriminated unions
      def discriminator
        @dump[:discriminator]
      end

      # @api public
      # @return [Object, nil] literal value
      def value
        @dump[:value]
      end

      # @api public
      # @return [Symbol, Array, nil] enum name reference or inline values
      def enum
        @dump[:enum]
      end

      # @api public
      # @return [Boolean] whether this field can be null
      def nullable?
        @dump[:nullable] == true
      end

      # @api public
      # @return [Boolean] whether this field is optional
      def optional?
        @dump[:optional] == true
      end

      # @api public
      # @return [Boolean] whether this field is deprecated
      def deprecated?
        @dump[:deprecated] == true
      end

      # @api public
      # @return [String, nil] field description
      def description
        @dump[:description]
      end

      # @api public
      # @return [Object, nil] example value
      def example
        @dump[:example]
      end

      # @api public
      # @return [Symbol, nil] format hint (e.g., :uuid, :email)
      def format
        @dump[:format]
      end

      # @api public
      # @return [Integer, nil] minimum value for numeric types
      def min
        @dump[:min]
      end

      # @api public
      # @return [Integer, nil] maximum value for numeric types
      def max
        @dump[:max]
      end

      # @api public
      # @return [Object, nil] default value
      def default
        @dump[:default]
      end

      # @api public
      # @return [Boolean] whether a default value is defined
      def default?
        @dump.key?(:default)
      end

      # @api public
      # @return [Boolean] whether this param is partial (for update payloads)
      def partial?
        @dump[:partial] == true
      end

      # @api public
      # Access raw data for edge cases not covered by accessors.
      #
      # @param key [Symbol] the data key to access
      # @return [Object, nil] the raw value
      def [](key)
        @dump[key]
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          default: default,
          deprecated: deprecated?,
          description: description,
          discriminator: discriminator,
          enum: enum,
          example: example,
          format: format,
          max: max,
          min: min,
          nullable: nullable?,
          of: of&.to_h,
          optional: optional?,
          partial: partial?,
          shape: shape.transform_values(&:to_h),
          type: type,
          value: value,
          variants: variants.map(&:to_h),
        }
      end
    end
  end
end
