# frozen_string_literal: true

module Apiwork
  module Spec
    class Data
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
      #   param.of           # => :string or { type: :object, shape: {...} }
      #
      # @example Object type
      #   param.object?      # => true
      #   param.shape[:name] # => Param for the name field
      class Param
        def initialize(data)
          @data = data || {}
        end

        # @api public
        # @return [Symbol, nil] type (:string, :integer, :array, :object, :union, etc.)
        def type
          @data[:type]
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
        # @return [Symbol, Hash, nil] element type for arrays
        def of
          @data[:of]
        end

        # @api public
        # @return [Hash{Symbol => Param}] nested fields for objects
        def shape
          @shape ||= (@data[:shape] || {}).transform_values { |d| Param.new(d) }
        end

        # @api public
        # @return [Array<Hash>] variants for unions
        def variants
          @data[:variants] || []
        end

        # @api public
        # @return [Symbol, nil] discriminator field for discriminated unions
        def discriminator
          @data[:discriminator]
        end

        # @api public
        # @return [Object, nil] literal value
        def value
          @data[:value]
        end

        # @api public
        # @return [Symbol, Array, nil] enum name reference or inline values
        def enum
          @data[:enum]
        end

        # @api public
        # @return [Boolean] whether this field can be null
        def nullable?
          @data[:nullable] == true
        end

        # @api public
        # @return [Boolean] whether this field is optional
        def optional?
          @data[:optional] == true
        end

        # @api public
        # @return [Boolean] whether this field is deprecated
        def deprecated?
          @data[:deprecated] == true
        end

        # @api public
        # @return [String, nil] field description
        def description
          @data[:description]
        end

        # @api public
        # @return [Object, nil] example value
        def example
          @data[:example]
        end

        # @api public
        # @return [Symbol, nil] format hint (e.g., :uuid, :email)
        def format
          @data[:format]
        end

        # @api public
        # @return [Integer, nil] minimum value for numeric types
        def min
          @data[:min]
        end

        # @api public
        # @return [Integer, nil] maximum value for numeric types
        def max
          @data[:max]
        end

        # @api public
        # @return [Object, nil] default value
        def default
          @data[:default]
        end

        # @api public
        # @return [Boolean] whether a default value is defined
        def default?
          @data.key?(:default)
        end

        # @api public
        # @return [Boolean] whether this param is partial (for update payloads)
        def partial?
          @data[:partial] == true
        end

        # @api public
        # Access raw data for edge cases not covered by accessors.
        #
        # @param key [Symbol] the data key to access
        # @return [Object, nil] the raw value
        def [](key)
          @data[key]
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          {
            type: type,
            of: of,
            shape: shape.transform_values(&:to_h),
            variants: variants,
            discriminator: discriminator,
            value: value,
            enum: enum,
            nullable: nullable?,
            optional: optional?,
            deprecated: deprecated?,
            description: description,
            example: example,
            format: format,
            min: min,
            max: max,
            default: default,
            partial: partial?
          }.compact
        end
      end
    end
  end
end
