# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Base
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # @return [Symbol] the parameter type
        #   :string, :integer, :float, :decimal, :boolean, :datetime, :date, :time,
        #   :uuid, :binary, :json, :unknown, :array, :object, :union, :literal, :ref
        def type
          @dump[:type]
        end

        # @api public
        # @return [Boolean] whether this field can be null
        def nullable?
          @dump[:nullable]
        end

        # @api public
        # @return [Boolean] whether this field is optional
        def optional?
          @dump[:optional]
        end

        # @api public
        # @return [Boolean] whether this field is deprecated
        def deprecated?
          @dump[:deprecated]
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
        # @return [Boolean] whether this is a numeric type (integer, float, decimal)
        def numeric?
          false
        end

        # @api public
        # @return [Boolean] whether this type supports min/max constraints
        def boundable?
          false
        end

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
        # @return [Boolean] whether this is a UUID type
        def uuid?
          false
        end

        # @api public
        # @return [Boolean] whether this is a binary type
        def binary?
          false
        end

        # @api public
        # @return [Boolean] whether this is a JSON type
        def json?
          false
        end

        # @api public
        # @return [Boolean] whether this is an unknown type
        def unknown?
          false
        end

        # @api public
        # @return [Boolean] whether this is a ref type
        def ref?
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
