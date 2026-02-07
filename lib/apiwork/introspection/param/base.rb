# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Base class for all introspection param types.
      #
      # Params represent field definitions with type information, constraints,
      # and metadata. Each param type (String, Integer, Array, Object, etc.)
      # extends this base class with type-specific behavior.
      #
      # @example Checking param properties
      #   param.type        # => :string
      #   param.optional?   # => true
      #   param.nullable?   # => false
      #   param.description # => "The user's email address"
      #
      # @example Type checking
      #   param.string?  # => true
      #   param.integer? # => false
      #   param.scalar?  # => true
      class Base
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # The param type (:string, :integer, :array, :object, etc.).
        # @return [Symbol]
        def type
          @dump[:type]
        end

        # @api public
        # Whether this field can be null.
        # @return [Boolean]
        def nullable?
          @dump[:nullable]
        end

        # @api public
        # Whether this field is optional.
        # @return [Boolean]
        def optional?
          @dump[:optional]
        end

        # @api public
        # Whether this field is deprecated.
        # @return [Boolean]
        def deprecated?
          @dump[:deprecated]
        end

        # @api public
        # The field description.
        # @return [String, nil]
        def description
          @dump[:description]
        end

        # @api public
        # The example value.
        # @return [Object, nil]
        def example
          @dump[:example]
        end

        # @api public
        # The default value.
        # @return [Object, nil]
        def default
          @dump[:default]
        end

        # @api public
        # Whether a default value is defined.
        # @return [Boolean]
        def default?
          @dump.key?(:default)
        end

        # @api public
        # The discriminator tag for union variants.
        # @return [String, nil]
        def tag
          @dump[:tag]
        end

        # @api public
        # Whether this is a scalar type.
        # @return [Boolean]
        def scalar?
          false
        end

        # @api public
        # Whether this is an array type.
        # @return [Boolean]
        def array?
          false
        end

        # @api public
        # Whether this is an object type.
        # @return [Boolean]
        def object?
          false
        end

        # @api public
        # Whether this is a union type.
        # @return [Boolean]
        def union?
          false
        end

        # @api public
        # Whether this is a literal type.
        # @return [Boolean]
        def literal?
          false
        end

        # @api public
        # Whether this is a numeric type.
        # @return [Boolean]
        def numeric?
          false
        end

        # @api public
        # Whether this type supports min/max bounds.
        # @return [Boolean]
        def boundable?
          false
        end

        # @api public
        # Whether this is a string type.
        # @return [Boolean]
        def string?
          false
        end

        # @api public
        # Whether this is an integer type.
        # @return [Boolean]
        def integer?
          false
        end

        # @api public
        # Whether this is a number type.
        # @return [Boolean]
        def number?
          false
        end

        # @api public
        # Whether this is a decimal type.
        # @return [Boolean]
        def decimal?
          false
        end

        # @api public
        # Whether this is a boolean type.
        # @return [Boolean]
        def boolean?
          false
        end

        # @api public
        # Whether this is a datetime type.
        # @return [Boolean]
        def datetime?
          false
        end

        # @api public
        # Whether this is a date type.
        # @return [Boolean]
        def date?
          false
        end

        # @api public
        # Whether this is a time type.
        # @return [Boolean]
        def time?
          false
        end

        # @api public
        # Whether this is a UUID type.
        # @return [Boolean]
        def uuid?
          false
        end

        # @api public
        # Whether this is a binary type.
        # @return [Boolean]
        def binary?
          false
        end

        # @api public
        # Whether this is an unknown type.
        # @return [Boolean]
        def unknown?
          false
        end

        # @api public
        # Whether this is a type reference.
        # @return [Boolean]
        def ref?
          false
        end

        # @api public
        # Whether this is an enum type.
        # @return [Boolean]
        def enum?
          false
        end

        # @api public
        # Whether this is an enum reference.
        # @return [Boolean]
        def enum_ref?
          false
        end

        # @api public
        # Whether this type supports format constraints.
        # @return [Boolean]
        def formattable?
          false
        end

        # @api public
        # Whether this is a partial object.
        # @return [Boolean]
        def partial?
          false
        end

        # @api public
        # Structured representation.
        # @return [Hash]
        def to_h
          {
            default: default,
            deprecated: deprecated?,
            description: description,
            example: example,
            nullable: nullable?,
            optional: optional?,
            type: type,
          }
        end
      end
    end
  end
end
