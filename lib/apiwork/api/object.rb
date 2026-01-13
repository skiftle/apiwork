# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining reusable object types.
    #
    # Accessed via `object :name do` in API or contract definitions.
    # Use type methods to define fields: {#string}, {#integer}, {#decimal},
    # {#boolean}, {#array}, {#object}, {#union}, {#reference}.
    #
    # @example Define a reusable type
    #   object :item do
    #     string :description
    #     decimal :amount
    #   end
    #
    # @example Reference in contract
    #   array :items do
    #     reference :item
    #   end
    #
    # @see Contract::Object Block context for inline objects
    # @see API::Element Block context for array/variant elements
    class Object
      attr_reader :params

      def initialize
        @params = {}
      end

      # @api public
      # Defines a field with explicit type.
      #
      # This is the verbose form. Prefer sugar methods (string, integer, etc.)
      # for static definitions. Use `param` for dynamic field generation.
      #
      # @param name [Symbol] field name
      # @param type [Symbol, nil] field type (:string, :integer, :object, :array, :union, or custom type reference)
      # @param as [Symbol, nil] target attribute name for mapping to model
      # @param default [Object, nil] default value when field is omitted
      # @param deprecated [Boolean, nil] mark field as deprecated
      # @param description [String, nil] documentation description
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param enum [Array, nil] allowed values (strings, integers only)
      # @param example [Object, nil] example value for documentation
      # @param format [Symbol, nil] format hint (strings only)
      # @param max [Integer, nil] maximum value or length (strings, integers, decimals, numbers, arrays only)
      # @param min [Integer, nil] minimum value or length (strings, integers, decimals, numbers, arrays only)
      # @param nullable [Boolean, nil] whether null is allowed
      # @param of [Symbol, Hash, nil] element type (arrays only)
      # @param optional [Boolean] whether field can be omitted
      # @param required [Boolean, nil] explicit required flag
      # @param shape [API::Object, API::Union, nil] pre-built shape (objects, arrays, unions only)
      # @param store [Boolean, nil] whether to persist the value
      # @param value [Object, nil] literal value (literals only)
      # @yield block for defining nested structure (objects, arrays, unions only)
      # @return [void]
      #
      # @example Basic usage
      #   param :title, :string
      #   param :count, :integer, min: 0
      #
      # @example With options
      #   param :status, :string, enum: %w[pending active], description: 'Current status'
      #
      # @example Extending existing param (type omitted)
      #   param :name, description: 'Updated description'
      #
      # @example Passing shape from schema element (adapter use)
      #   attribute = schema_class.attributes[:settings]
      #   param :settings, :object, shape: attribute.element.shape
      def param(
        name,
        type = nil,
        as: nil,
        default: nil,
        deprecated: nil,
        description: nil,
        discriminator: nil,
        enum: nil,
        example: nil,
        format: nil,
        max: nil,
        min: nil,
        nullable: nil,
        of: nil,
        optional: false,
        required: nil,
        shape: nil,
        store: nil,
        value: nil,
        &block
      )
        resolved_of = of
        resolved_shape = shape

        if block && type == :array
          element = Element.new
          element.instance_eval(&block)
          element.validate!
          resolved_of = element.of_type
          resolved_shape = element.shape
          discriminator = element.discriminator
        else
          resolved_shape ||= build_shape(type, discriminator, &block)
        end

        @params[name] = (@params[name] || {}).merge(
          {
            as:,
            default:,
            deprecated:,
            description:,
            discriminator:,
            enum:,
            example:,
            format:,
            max:,
            min:,
            name:,
            nullable:,
            optional:,
            required:,
            store:,
            type:,
            value:,
            of: resolved_of,
            shape: resolved_shape,
          }.compact,
        )
      end

      # @api public
      # Defines a string field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param enum [Array] allowed values
      # @param example [String] example value for documentation
      # @param format [String] format hint
      # @param max [Integer] maximum length
      # @param min [Integer] minimum length
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      #
      # @example
      #   string :title
      #   string :status, enum: %w[pending active]
      def string(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        enum: nil,
        example: nil,
        format: nil,
        max: nil,
        min: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :string,
          as:,
          deprecated:,
          description:,
          enum:,
          example:,
          format:,
          max:,
          min:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines an integer field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param enum [Array] allowed values
      # @param example [Integer] example value for documentation
      # @param max [Integer] maximum value
      # @param min [Integer] minimum value
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      #
      # @example
      #   integer :count
      #   integer :age, min: 0, max: 150
      def integer(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        enum: nil,
        example: nil,
        max: nil,
        min: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :integer,
          as:,
          deprecated:,
          description:,
          enum:,
          example:,
          max:,
          min:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a decimal field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [Numeric] example value for documentation
      # @param max [Numeric] maximum value
      # @param min [Numeric] minimum value
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      #
      # @example
      #   decimal :amount
      #   decimal :price, min: 0
      def decimal(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        max: nil,
        min: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :decimal,
          as:,
          deprecated:,
          description:,
          example:,
          max:,
          min:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a boolean field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [Boolean] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      #
      # @example
      #   boolean :active
      def boolean(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :boolean,
          as:,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a number field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [Float] example value for documentation
      # @param max [Float] maximum value
      # @param min [Float] minimum value
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def number(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        max: nil,
        min: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :number,
          as:,
          deprecated:,
          description:,
          example:,
          max:,
          min:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a datetime field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def datetime(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :datetime,
          as:,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a date field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def date(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :date,
          as:,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a UUID field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def uuid(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :uuid,
          as:,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a time field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def time(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :time,
          as:,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a binary field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def binary(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :binary,
          as:,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines a literal value field.
      #
      # @param name [Symbol] field name
      # @param value [Object] the exact value (required)
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      #
      # @example
      #   literal :type, value: 'card'
      #   literal :version, value: 1
      def literal(
        name,
        value:,
        as: nil,
        deprecated: nil,
        description: nil,
        optional: false,
        store: nil
      )
        param(
          name,
          :literal,
          as:,
          deprecated:,
          description:,
          optional:,
          store:,
          value:,
        )
      end

      # @api public
      # Defines a reference to a named type.
      #
      # @param name [Symbol] field name
      # @param to [Symbol] target type name (defaults to field name)
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      #
      # @example Same name
      #   reference :invoice
      #
      # @example Different name
      #   reference :shipping_address, to: :address
      def reference(
        name,
        to: nil,
        as: nil,
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false
      )
        resolved_type = to || name
        param(
          name,
          resolved_type,
          as:,
          deprecated:,
          description:,
          nullable:,
          optional:,
        )
      end

      # @api public
      # Defines an array field.
      #
      # The block must define exactly one element type.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @yield block defining element type
      # @return [void]
      # @see API::Element
      #
      # @example Array of integers
      #   array :ids do
      #     integer
      #   end
      #
      # @example Array of references
      #   array :items do
      #     reference :item
      #   end
      #
      # @example Array of inline objects
      #   array :lines do
      #     object do
      #       string :description
      #       decimal :amount
      #     end
      #   end
      def array(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false,
        &block
      )
        raise ArgumentError, 'array requires a block' unless block

        element = Element.new
        element.instance_eval(&block)
        element.validate!

        param(
          name,
          :array,
          as:,
          deprecated:,
          description:,
          nullable:,
          optional:,
          of: {
            enum: element.enum,
            format: element.format,
            max: element.max,
            min: element.min,
            type: element.of_type,
          }.compact,
          shape: element.shape,
        )
      end

      # @api public
      # Defines an inline object field.
      #
      # @param name [Symbol] field name
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @yield block defining object fields
      # @return [void]
      # @see API::Object
      #
      # @example
      #   object :customer do
      #     string :name
      #     string :email
      #   end
      def object(
        name,
        as: nil,
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false,
        &block
      )
        param(
          name,
          :object,
          as:,
          deprecated:,
          description:,
          nullable:,
          optional:,
          &block
        )
      end

      # @api public
      # Defines an inline union field.
      #
      # @param name [Symbol] field name
      # @param discriminator [Symbol] discriminator field for tagged unions
      # @param as [Symbol] target attribute name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @yield block defining union variants
      # @return [void]
      # @see API::Union
      #
      # @example
      #   union :payment_method, discriminator: :type do
      #     variant tag: 'card' do
      #       object do
      #         string :last_four
      #       end
      #     end
      #   end
      def union(
        name,
        discriminator: nil,
        as: nil,
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false,
        &block
      )
        param(
          name,
          :union,
          as:,
          deprecated:,
          description:,
          discriminator:,
          nullable:,
          optional:,
          &block
        )
      end

      private

      def build_shape(type, discriminator, &block)
        return nil unless block

        case type
        when :object
          builder = Object.new
          builder.instance_eval(&block)
          builder
        when :union
          builder = Union.new(discriminator:)
          builder.instance_eval(&block)
          builder
        end
      end
    end
  end
end
