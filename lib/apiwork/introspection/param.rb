# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Base class for parameter/field definitions.
    #
    # Use {.build} to create the appropriate subclass based on type.
    #
    # @example Basic usage
    #   param = Param.build(dump)
    #   param.type         # => :string
    #   param.nullable?    # => false
    #   param.optional?    # => true
    #
    # @example Type-specific subclasses
    #   param = Param.build(type: :array, of: { type: :string })
    #   param.class        # => ArrayParam
    #   param.array?       # => true
    #   param.of           # => StringParam
    class Param
      # @api public
      # Factory method to create the appropriate Param subclass.
      #
      # @param dump [Hash] the param dump
      # @return [Param] the appropriate subclass instance
      def self.build(dump)
        type = dump[:type]

        # Check for enum (inline or reference)
        if dump[:enum]
          return dump[:enum].is_a?(Array) ? InlineEnumParam.new(dump) : EnumRefParam.new(dump)
        end

        case type
        when :string then StringParam.new(dump)
        when :integer then IntegerParam.new(dump)
        when :float then FloatParam.new(dump)
        when :decimal then DecimalParam.new(dump)
        when :boolean then BooleanParam.new(dump)
        when :datetime then DateTimeParam.new(dump)
        when :date then DateParam.new(dump)
        when :time then TimeParam.new(dump)
        when :uuid then UuidParam.new(dump)
        when :binary then BinaryParam.new(dump)
        when :json then JsonParam.new(dump)
        when :unknown then UnknownParam.new(dump)
        when :array then ArrayParam.new(dump)
        when :object then ObjectParam.new(dump)
        when :union then UnionParam.new(dump)
        when :literal then LiteralParam.new(dump)
        when Symbol then TypeRefParam.new(dump)
        else UnknownParam.new(dump)
        end
      end

      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [Symbol, nil] type (:string, :integer, :array, :object, :union, etc.)
      def type
        @dump[:type]
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
      # Access raw data for edge cases not covered by accessors.
      #
      # @param key [Symbol] the data key to access
      # @return [Object, nil] the raw value
      def [](key)
        @dump[key]
      end

      # Predicate methods - return false by default, overridden in subclasses

      # @api public
      # @return [Boolean] whether this is a string type
      def string?
        false
      end

      # @api public
      # @return [Boolean] whether this is an integer type
      def integer?
        false
      end

      # @api public
      # @return [Boolean] whether this is a float type
      def float?
        false
      end

      # @api public
      # @return [Boolean] whether this is a decimal type
      def decimal?
        false
      end

      # @api public
      # @return [Boolean] whether this is a boolean type
      def boolean?
        false
      end

      # @api public
      # @return [Boolean] whether this is a datetime type
      def datetime?
        false
      end

      # @api public
      # @return [Boolean] whether this is a date type
      def date?
        false
      end

      # @api public
      # @return [Boolean] whether this is a time type
      def time?
        false
      end

      # @api public
      # @return [Boolean] whether this is a uuid type
      def uuid?
        false
      end

      # @api public
      # @return [Boolean] whether this is a binary type
      def binary?
        false
      end

      # @api public
      # @return [Boolean] whether this is a json type
      def json?
        false
      end

      # @api public
      # @return [Boolean] whether this is an unknown type
      def unknown?
        false
      end

      # @api public
      # @return [Boolean] whether this is an array type
      def array?
        false
      end

      # @api public
      # @return [Boolean] whether this is an object type
      def object?
        false
      end

      # @api public
      # @return [Boolean] whether this is a union type
      def union?
        false
      end

      # @api public
      # @return [Boolean] whether this is a literal type
      def literal?
        false
      end

      # @api public
      # @return [Boolean] whether this is a type reference
      def type_ref?
        false
      end

      # @api public
      # @return [Boolean] whether this is an enum reference
      def enum_ref?
        false
      end

      # @api public
      # @return [Boolean] whether this is an inline enum
      def inline_enum?
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
