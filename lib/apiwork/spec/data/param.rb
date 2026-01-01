# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
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

        # @return [Symbol, nil] type (:string, :integer, :array, :object, :union, etc.)
        def type
          @data[:type]
        end

        # @return [Boolean] whether this is an array type
        def array?
          type == :array
        end

        # @return [Boolean] whether this is an object type
        def object?
          type == :object
        end

        # @return [Boolean] whether this is a union type
        def union?
          type == :union
        end

        # @return [Boolean] whether this is a literal type
        def literal?
          type == :literal
        end

        # @return [Symbol, Hash, nil] element type for arrays
        def of
          @data[:of]
        end

        # @return [Hash{Symbol => Param}] nested fields for objects
        def shape
          @shape ||= (@data[:shape] || {}).transform_values { |d| Param.new(d) }
        end

        # @return [Array<Hash>] variants for unions
        def variants
          @data[:variants] || []
        end

        # @return [Symbol, nil] discriminator field for discriminated unions
        def discriminator
          @data[:discriminator]
        end

        # @return [Object, nil] literal value
        def value
          @data[:value]
        end

        # @return [Symbol, Array, nil] enum name reference or inline values
        def enum
          @data[:enum]
        end

        # @return [Boolean] whether this field can be null
        def nullable?
          @data[:nullable] == true
        end

        # @return [Boolean] whether this field is optional
        def optional?
          @data[:optional] == true
        end

        # @return [Boolean] whether this field is deprecated
        def deprecated?
          @data[:deprecated] == true
        end

        # @return [String, nil] field description
        def description
          @data[:description]
        end

        # @return [Object, nil] example value
        def example
          @data[:example]
        end

        # @return [Symbol, nil] format hint (e.g., :uuid, :email)
        def format
          @data[:format]
        end

        # @return [Integer, nil] minimum value for numeric types
        def min
          @data[:min]
        end

        # @return [Integer, nil] maximum value for numeric types
        def max
          @data[:max]
        end

        # @return [Object, nil] default value
        def default
          @data[:default]
        end

        # @return [Boolean] whether a default value is defined
        def default?
          @data.key?(:default)
        end

        # @return [Boolean] whether this param is partial (for update payloads)
        def partial?
          @data[:partial] == true
        end

        # Access raw data for edge cases not covered by accessors.
        #
        # @param key [Symbol] the data key to access
        # @return [Object, nil] the raw value
        def [](key)
          @data[key]
        end

        # @return [Hash] the raw underlying data hash
        def to_h
          @data
        end
      end
    end
  end
end
