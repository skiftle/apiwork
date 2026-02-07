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
        # The type for this param.
        #
        # @return [Symbol]
        def type
          @dump[:type]
        end

        # @api public
        # Whether this param is nullable.
        #
        # @return [Boolean]
        def nullable?
          @dump[:nullable]
        end

        # @api public
        # Whether this param is optional.
        #
        # @return [Boolean]
        def optional?
          @dump[:optional]
        end

        # @api public
        # Whether this param is deprecated.
        #
        # @return [Boolean]
        def deprecated?
          @dump[:deprecated]
        end

        # @api public
        # The description for this param.
        #
        # @return [String, nil]
        def description
          @dump[:description]
        end

        # @api public
        # The example value for this param.
        #
        # @return [Object, nil]
        def example
          @dump[:example]
        end

        # @api public
        # The default value for this param.
        #
        # @return [Object, nil]
        def default
          @dump[:default]
        end

        # @api public
        # Whether this param has a default value.
        #
        # @return [Boolean]
        def default?
          @dump.key?(:default)
        end

        # @api public
        # The discriminator tag for this param.
        #
        # @return [String, nil]
        def tag
          @dump[:tag]
        end

        # @api public
        # Whether this param is scalar.
        #
        # @return [Boolean]
        def scalar?
          false
        end

        # @api public
        # Whether this param is an array.
        #
        # @return [Boolean]
        def array?
          false
        end

        # @api public
        # Whether this param is an object.
        #
        # @return [Boolean]
        def object?
          false
        end

        # @api public
        # Whether this param is a union.
        #
        # @return [Boolean]
        def union?
          false
        end

        # @api public
        # Whether this param is a literal.
        #
        # @return [Boolean]
        def literal?
          false
        end

        # @api public
        # Whether this param is numeric.
        #
        # @return [Boolean]
        def numeric?
          false
        end

        # @api public
        # Whether this param is boundable.
        #
        # @return [Boolean]
        def boundable?
          false
        end

        # @api public
        # Whether this param is a string.
        #
        # @return [Boolean]
        def string?
          false
        end

        # @api public
        # Whether this param is an integer.
        #
        # @return [Boolean]
        def integer?
          false
        end

        # @api public
        # Whether this param is a number.
        #
        # @return [Boolean]
        def number?
          false
        end

        # @api public
        # Whether this param is a decimal.
        #
        # @return [Boolean]
        def decimal?
          false
        end

        # @api public
        # Whether this param is a boolean.
        #
        # @return [Boolean]
        def boolean?
          false
        end

        # @api public
        # Whether this param is a datetime.
        #
        # @return [Boolean]
        def datetime?
          false
        end

        # @api public
        # Whether this param is a date.
        #
        # @return [Boolean]
        def date?
          false
        end

        # @api public
        # Whether this param is a time.
        #
        # @return [Boolean]
        def time?
          false
        end

        # @api public
        # Whether this param is a UUID.
        #
        # @return [Boolean]
        def uuid?
          false
        end

        # @api public
        # Whether this param is binary.
        #
        # @return [Boolean]
        def binary?
          false
        end

        # @api public
        # Whether this param is unknown.
        #
        # @return [Boolean]
        def unknown?
          false
        end

        # @api public
        # Whether this param is a reference.
        #
        # @return [Boolean]
        def ref?
          false
        end

        # @api public
        # Whether this param is an enum.
        #
        # @return [Boolean]
        def enum?
          false
        end

        # @api public
        # Whether this param is an enum reference.
        #
        # @return [Boolean]
        def enum_ref?
          false
        end

        # @api public
        # Whether this param is formattable.
        #
        # @return [Boolean]
        def formattable?
          false
        end

        # @api public
        # Whether this param is partial.
        #
        # @return [Boolean]
        def partial?
          false
        end

        # @api public
        # Converts this param to a hash.
        #
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
