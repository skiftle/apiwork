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
      # Defines a parameter within this object.
      #
      # @param name [Symbol] parameter name
      # @param type [Symbol] primitive type or reference to named object/union
      # @param as [Symbol] internal name transformation
      # @param default [Object] default value when omitted
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param discriminator [Symbol] discriminator field for inline unions
      # @param enum [Symbol, Array] enum reference or inline values
      # @param example [Object] example value for documentation
      # @param format [String] format hint for documentation
      # @param internal [Hash] internal metadata for adapters
      # @param max [Numeric] maximum value constraint
      # @param min [Numeric] minimum value constraint
      # @param nullable [Boolean] whether the value can be null
      # @param of [Symbol] element type for arrays
      # @param optional [Boolean] whether the parameter can be omitted
      # @param required [Boolean] alias for optional: false
      # @param shape [Object] pre-built shape for arrays
      # @param value [Object] literal value constraint
      # @return [void]
      # @see API::Object
      # @see API::Union
      #
      # @example Basic param
      #   decimal :amount
      #
      # @example Inline object
      #   object :customer do
      #     string :name
      #   end
      #
      # @example Inline union
      #   union :payment_method, discriminator: :type do
      #     variant tag: 'card' do
      #       object do
      #         string :last_four
      #       end
      #     end
      #     variant tag: 'bank' do
      #       object do
      #         string :account_number
      #       end
      #     end
      #   end
      def param(
        name,
        type: nil,
        as: nil,
        default: nil,
        deprecated: nil,
        description: nil,
        discriminator: nil,
        enum: nil,
        example: nil,
        format: nil,
        internal: nil,
        max: nil,
        min: nil,
        nullable: nil,
        of: nil,
        optional: false,
        required: nil,
        shape: nil,
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
            internal:,
            max:,
            min:,
            name:,
            nullable:,
            optional:,
            required:,
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
          deprecated:,
          description:,
          enum:,
          example:,
          format:,
          max:,
          min:,
          nullable:,
          optional:,
          type: :string,
        )
      end

      # @api public
      # Defines an integer field.
      #
      # @param name [Symbol] field name
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
          deprecated:,
          description:,
          enum:,
          example:,
          max:,
          min:,
          nullable:,
          optional:,
          type: :integer,
        )
      end

      # @api public
      # Defines a decimal field.
      #
      # @param name [Symbol] field name
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
          deprecated:,
          description:,
          example:,
          max:,
          min:,
          nullable:,
          optional:,
          type: :decimal,
        )
      end

      # @api public
      # Defines a boolean field.
      #
      # @param name [Symbol] field name
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
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
          type: :boolean,
        )
      end

      # @api public
      # Defines a float field.
      #
      # @param name [Symbol] field name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [Float] example value for documentation
      # @param max [Float] maximum value
      # @param min [Float] minimum value
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def float(
        name,
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
          deprecated:,
          description:,
          example:,
          max:,
          min:,
          nullable:,
          optional:,
          type: :float,
        )
      end

      # @api public
      # Defines a datetime field.
      #
      # @param name [Symbol] field name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def datetime(
        name,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
          type: :datetime,
        )
      end

      # @api public
      # Defines a date field.
      #
      # @param name [Symbol] field name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def date(
        name,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
          type: :date,
        )
      end

      # @api public
      # Defines a UUID field.
      #
      # @param name [Symbol] field name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def uuid(
        name,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          deprecated:,
          description:,
          example:,
          nullable:,
          optional:,
          type: :uuid,
        )
      end

      # @api public
      # Defines a literal value field.
      #
      # @param name [Symbol] field name
      # @param value [Object] the exact value (required)
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
        deprecated: nil,
        description: nil,
        optional: false
      )
        param(
          name,
          deprecated:,
          description:,
          optional:,
          value:,
          type: :literal,
        )
      end

      # @api public
      # Defines a reference to a named type.
      #
      # @param name [Symbol] field name
      # @param to [Symbol] target type name (defaults to field name)
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
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false
      )
        resolved_type = to || name
        param(
          name,
          deprecated:,
          description:,
          nullable:,
          optional:,
          type: resolved_type,
        )
      end

      # @api public
      # Defines an array field.
      #
      # The block must define exactly one element type.
      #
      # @param name [Symbol] field name
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
          type: :array,
        )
      end

      # @api public
      # Defines an inline object field.
      #
      # @param name [Symbol] field name
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
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false,
        &block
      )
        param(
          name,
          deprecated:,
          description:,
          nullable:,
          optional:,
          type: :object,
          &block
        )
      end

      # @api public
      # Defines an inline union field.
      #
      # @param name [Symbol] field name
      # @param discriminator [Symbol] discriminator field for tagged unions
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
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false,
        &block
      )
        param(
          name,
          deprecated:,
          description:,
          discriminator:,
          nullable:,
          optional:,
          type: :union,
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
