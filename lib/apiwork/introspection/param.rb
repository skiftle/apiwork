# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Base class for parameter/field definitions.
    #
    # Params are accessed via introspection - you never create them directly.
    #
    # @example Accessing params via introspection
    #   api = Apiwork::Introspection::API.new(MyApi)
    #   action = api.resources[:invoices].actions[:show]
    #   param = action.request.query[:page]
    #   param.type         # => :integer
    #   param.optional?    # => true
    #
    # @example Type-specific subclasses
    #   param = action.response.body  # => ArrayParam
    #   param.of                      # => ObjectParam (element type)
    class Param
      def self.build(dump)
        type = dump[:type]

        # Check for enum (inline or reference)
        if dump[:enum]
          return dump[:enum].is_a?(Array) ? InlineEnumParam.new(dump) : RefEnumParam.new(dump)
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
        when :uuid then UUIDParam.new(dump)
        when :binary then BinaryParam.new(dump)
        when :json then JSONParam.new(dump)
        when :unknown then UnknownParam.new(dump)
        when :array then ArrayParam.new(dump)
        when :object then ObjectParam.new(dump)
        when :union then UnionParam.new(dump)
        when :literal then LiteralParam.new(dump)
        when Symbol then RefTypeParam.new(dump)
        else UnknownParam.new(dump)
        end
      end

      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [Symbol, nil] the parameter type
      #   Scalar types: :string, :integer, :float, :decimal, :boolean,
      #   :datetime, :date, :time, :uuid, :binary, :json, :unknown
      #   Container types: :array, :object, :union, :literal
      #   Reference types: any Symbol (custom type reference)
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
      # @return [String, nil] discriminator tag for union variants
      def tag
        @dump[:tag]
      end

      # @api public
      # @return [Boolean] whether this is a scalar type
      def scalar?
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
