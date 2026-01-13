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
        # @return [Symbol] the param type (:string, :integer, :array, :object, etc.)
        def type
          @dump[:type]
        end

        # @api public
        # @return [Boolean] true if this field can be null
        def nullable?
          @dump[:nullable]
        end

        # @api public
        # @return [Boolean] true if this field is optional
        def optional?
          @dump[:optional]
        end

        # @api public
        # @return [Boolean] true if this field is deprecated
        def deprecated?
          @dump[:deprecated]
        end

        # @api public
        # @return [String, nil] the field description
        def description
          @dump[:description]
        end

        # @api public
        # @return [Object, nil] the example value
        def example
          @dump[:example]
        end

        # @api public
        # @return [Object, nil] the default value
        def default
          @dump[:default]
        end

        # @api public
        # @return [Boolean] true if a default value is defined
        def default?
          @dump.key?(:default)
        end

        # @api public
        # @return [String, nil] the discriminator tag for union variants
        def tag
          @dump[:tag]
        end

        # @api public
        # @return [Boolean] false — override in scalar subclasses
        def scalar?
          false
        end

        # @api public
        # @return [Boolean] false — override in Array
        def array?
          false
        end

        # @api public
        # @return [Boolean] false — override in Object
        def object?
          false
        end

        # @api public
        # @return [Boolean] false — override in Union
        def union?
          false
        end

        # @api public
        # @return [Boolean] false — override in Literal
        def literal?
          false
        end

        # @api public
        # @return [Boolean] false — override in Integer, Number, Decimal
        def numeric?
          false
        end

        # @api public
        # @return [Boolean] false — override in types that support min/max
        def boundable?
          false
        end

        # @api public
        # @return [Boolean] false — override in String
        def string?
          false
        end

        # @api public
        # @return [Boolean] false — override in Integer
        def integer?
          false
        end

        # @api public
        # @return [Boolean] false — override in Number
        def number?
          false
        end

        # @api public
        # @return [Boolean] false — override in Decimal
        def decimal?
          false
        end

        # @api public
        # @return [Boolean] false — override in Boolean
        def boolean?
          false
        end

        # @api public
        # @return [Boolean] false — override in DateTime
        def datetime?
          false
        end

        # @api public
        # @return [Boolean] false — override in Date
        def date?
          false
        end

        # @api public
        # @return [Boolean] false — override in Time
        def time?
          false
        end

        # @api public
        # @return [Boolean] false — override in UUID
        def uuid?
          false
        end

        # @api public
        # @return [Boolean] false — override in Binary
        def binary?
          false
        end

        # @api public
        # @return [Boolean] false — override in Unknown
        def unknown?
          false
        end

        # @api public
        # @return [Boolean] false — override in Ref
        def ref?
          false
        end

        # @api public
        # @return [Boolean] false — override in scalar types with enum constraints
        def enum?
          false
        end

        # @api public
        # @return [Boolean] false — override in scalar types
        def enum_ref?
          false
        end

        # @api public
        # @return [Boolean] false — override in String, Integer
        def formattable?
          false
        end

        # @api public
        # @return [Boolean] false — override in Object
        def partial?
          false
        end

        # @api public
        # @return [Hash] structured representation
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
