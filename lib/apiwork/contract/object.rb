# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Block context for defining request/response structure.
    #
    # Accessed via `body do`, `query do`, or `object :x do`
    # inside contract actions. Use type methods to define fields.
    #
    # @example Request body
    #   body do
    #     string :title
    #     decimal :amount
    #   end
    #
    # @example Inline nested object
    #   object :customer do
    #     string :name
    #   end
    #
    # @see API::Object Block context for reusable types
    class Object
      attr_reader :action_name,
                  :contract_class,
                  :params

      attr_accessor :visited_types

      def initialize(contract_class, action_name: nil, wrapped: false)
        @contract_class = contract_class
        @action_name = action_name
        @wrapped = wrapped
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
      # @param enum [Array, Symbol, nil] allowed values or enum reference (strings, integers only)
      # @param example [Object, nil] example value for documentation
      # @param format [Symbol, nil] format hint (strings only)
      # @param max [Integer, nil] maximum value or length (strings, integers, decimals, numbers, arrays only)
      # @param min [Integer, nil] minimum value or length (strings, integers, decimals, numbers, arrays only)
      # @param nullable [Boolean, nil] whether null is allowed
      # @param of [Symbol, Hash, nil] element type (arrays only)
      # @param optional [Boolean, nil] whether field can be omitted
      # @param required [Boolean, nil] explicit required flag
      # @param shape [Contract::Object, Contract::Union, nil] pre-built shape (objects, arrays, unions only)
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
        options = {
          deprecated:,
          description:,
          example:,
          format:,
          max:,
          min:,
          nullable:,
          required:,
          store:,
        }.compact

        raise ArgumentError, 'discriminator can only be used with type: :union' if discriminator && type != :union

        visited_types ||= @visited_types
        visited_types ||= Set.new

        resolved_enum = resolve_enum(enum)

        case type
        when :literal
          define_literal_param(name, as:, default:, deprecated:, description:, optional:, store:, value:)
        when :union
          define_union_param(
            name,
            as:,
            default:,
            discriminator:,
            optional:,
            options:,
            resolved_enum:,
            &block
          )
        else
          define_regular_param(
            name,
            as:,
            default:,
            of:,
            optional:,
            options:,
            resolved_enum:,
            shape:,
            type:,
            visited_types:,
            &block
          )
        end
      end

      # @api public
      # Defines a string field.
      #
      # @param name [Symbol] field name
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param enum [Array, Symbol] allowed values or enum reference
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
        default: nil,
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
          default:,
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
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param enum [Array, Symbol] allowed values or enum reference
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
        default: nil,
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
          default:,
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
        default: nil,
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
          default:,
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
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :boolean,
          default:,
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
      # @param default [Float] default value
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
        default: nil,
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
          default:,
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
      # @param default [String] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def datetime(
        name,
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :datetime,
          default:,
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
      # @param default [String] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def date(
        name,
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :date,
          default:,
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
      # @param default [String] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def uuid(
        name,
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :uuid,
          default:,
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
      # @param default [String] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def time(
        name,
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :time,
          default:,
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
      # @param default [String] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param example [String] example value for documentation
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @return [void]
      def binary(
        name,
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          :binary,
          default:,
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
          resolved_type,
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
      # @param default [Array] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @yield block defining element type
      # @return [void]
      # @see Contract::Element
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
        default: nil,
        deprecated: nil,
        description: nil,
        nullable: nil,
        optional: false,
        &block
      )
        raise ArgumentError, 'array requires a block' unless block

        element = Element.new(@contract_class)
        element.instance_eval(&block)
        element.validate!

        param(
          name,
          :array,
          default:,
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
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @yield block defining object fields
      # @return [void]
      # @see Contract::Object
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
          :object,
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
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param nullable [Boolean] whether null is allowed
      # @param optional [Boolean] whether field can be omitted
      # @yield block defining union variants
      # @return [void]
      # @see Contract::Union
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
          :union,
          deprecated:,
          description:,
          discriminator:,
          nullable:,
          optional:,
          &block
        )
      end

      # @api public
      # Shorthand for `object :meta do ... end`.
      #
      # Use for response data that doesn't belong to the resource itself.
      #
      # @param optional [Boolean] whether meta can be omitted (default: false)
      # @yield block defining meta params
      #
      # @example Required meta (default)
      #   response do
      #     body do
      #       meta do
      #         datetime :generated_at
      #       end
      #     end
      #   end
      #
      # @example Optional meta
      #   response do
      #     body do
      #       meta optional: true do
      #         string :api_version
      #       end
      #     end
      #   end
      def meta(optional: false, &block)
        return unless block

        existing_meta = @params[:meta]

        if existing_meta && existing_meta[:shape]
          existing_meta[:shape].instance_eval(&block)
        else
          param :meta, :object, optional:, &block
        end
      end

      def validate(data, current_depth: 0, max_depth: 10, path: [])
        ParamValidator.new(self).validate(data, current_depth:, max_depth:, path:)
      end

      def wrapped?
        @wrapped
      end

      def copy_type_definition_params(type_definition, target_param)
        return unless type_definition.object?

        type_definition.params&.each do |param_name, param_data|
          nested_shape = param_data[:shape]

          if param_data[:type] == :array && nested_shape.is_a?(Apiwork::API::Object)
            target_param.param(param_name, param_data[:type], **param_data.except(:name, :type))
          elsif nested_shape.is_a?(API::Object)
            copy_nested_object_param(target_param, param_name, param_data, nested_shape)
          elsif nested_shape.is_a?(API::Union)
            copy_nested_union_param(target_param, param_name, param_data, nested_shape)
          else
            target_param.param(param_name, param_data[:type], **param_data.except(:name, :type, :shape))
          end
        end
      end

      private

      def copy_nested_object_param(target_param, param_name, param_data, nested_shape)
        target_param.param(
          param_name,
          param_data[:type],
          **param_data.except(:name, :type, :shape),
        ) do
          nested_shape.params.each do |nested_name, nested_data|
            param(nested_name, nested_data[:type], **nested_data.except(:name, :type, :shape))
          end
        end
      end

      def copy_nested_union_param(target_param, param_name, param_data, nested_shape)
        target_param.param(
          param_name,
          param_data[:type],
          **param_data.except(:name, :type, :shape),
        ) do
          nested_shape.variants.each do |variant_data|
            variant_shape = variant_data[:shape]
            variant_type = variant_data[:type]
            variant_tag = variant_data[:tag]
            variant_custom_type = variant_data[:custom_type]

            if variant_shape.is_a?(API::Object)
              variant tag: variant_tag do
                object do
                  variant_shape.params.each do |vp_name, vp_data|
                    param(vp_name, vp_data[:type], **vp_data.except(:name, :type, :shape))
                  end
                end
              end
            elsif variant_custom_type
              variant tag: variant_tag do
                reference variant_custom_type
              end
            else
              variant tag: variant_tag do
                send(variant_type)
              end
            end
          end
        end
      end

      def apply_param_defaults(param_hash)
        {
          as: nil,
          default: nil,
          enum: nil,
          nullable: nil,
          of: nil,
          optional: false,
          shape: nil,
        }.merge(param_hash)
      end

      def define_literal_param(name, as:, default:, deprecated:, description:, optional:, store:, value:)
        raise ArgumentError, 'Literal type requires a value parameter' if value.nil?

        @params[name] = apply_param_defaults(
          {
            as:,
            default:,
            deprecated:,
            description:,
            name:,
            optional:,
            store:,
            value:,
            type: :literal,
          },
        )
      end

      def define_union_param(name, as:, default:, discriminator:, optional:, options:, resolved_enum:, &block)
        raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

        union = Union.new(@contract_class, discriminator:)
        union.instance_eval(&block)

        @params[name] = apply_param_defaults(
          {
            name:,
            type: :union,
            optional:,
            default:,
            as:,
            union:,
            discriminator:,
            enum: resolved_enum,
            **options,
          },
        )
      end

      def define_regular_param(name, as:, default:, of:, optional:, options:, resolved_enum:, shape:, type:, visited_types:, &block)
        type_definition = @contract_class.resolve_custom_type(type)

        if type_definition
          expansion_key = [@contract_class.object_id, type]

          type_definition = nil if visited_types.include?(expansion_key)
        end

        if type_definition&.object?
          define_custom_type_param(
            name,
            as:,
            default:,
            of:,
            optional:,
            options:,
            resolved_enum:,
            type:,
            type_definition:,
            visited_types:,
            &block
          )
        elsif type_definition&.union?
          define_custom_union_type_param(
            name,
            as:,
            default:,
            optional:,
            options:,
            resolved_enum:,
            type:,
            type_definition:,
          )
        else
          define_standard_param(
            name,
            as:,
            default:,
            of:,
            optional:,
            options:,
            resolved_enum:,
            shape:,
            type:,
            &block
          )
        end
      end

      def define_custom_union_type_param(
        name,
        type:,
        type_definition:,
        resolved_enum:,
        optional:,
        default:,
        as:,
        options:
      )
        union = Union.new(@contract_class, discriminator: type_definition.discriminator)

        type_definition.variants.each do |variant_data|
          variant_shape = variant_data[:shape]
          variant_type = variant_data[:type]
          variant_tag = variant_data[:tag]
          variant_custom_type = variant_data[:custom_type]

          if variant_shape.is_a?(API::Object)
            union.variant tag: variant_tag do
              object do
                variant_shape.params.each do |vp_name, vp_data|
                  param(vp_name, vp_data[:type], **vp_data.except(:name, :shape, :type))
                end
              end
            end
          elsif variant_custom_type
            union.variant tag: variant_tag do
              reference variant_custom_type
            end
          else
            union.variant tag: variant_tag do
              send(variant_type)
            end
          end
        end

        @params[name] = apply_param_defaults(
          {
            name:,
            type: :union,
            optional:,
            default:,
            as:,
            union:,
            discriminator: type_definition.discriminator,
            custom_type: type,
            enum: resolved_enum,
            **options,
          },
        )
      end

      def define_custom_type_param(
        name,
        type:,
        type_definition:,
        resolved_enum:,
        optional:,
        default:,
        of:,
        as:,
        visited_types:,
        options:,
        &block
      )
        expansion_key = [@contract_class.object_id, type]

        visited_with_current = visited_types.dup.add(expansion_key)

        shape_param_definition = Object.new(@contract_class, action_name: @action_name)
        shape_param_definition.visited_types = visited_with_current

        copy_type_definition_params(type_definition, shape_param_definition)

        shape_param_definition.instance_eval(&block) if block_given?

        @params[name] = apply_param_defaults(
          {
            name:,
            type: :object,
            optional:,
            default:,
            enum: resolved_enum,
            of:,
            as:,
            custom_type: type,
            shape: shape_param_definition,
            **options,
          },
        )
      end

      def define_standard_param(name, as:, default:, of:, optional:, options:, resolved_enum:, shape:, type:, &block)
        resolved_of = of
        resolved_shape = shape

        if block_given? && type == :array
          element = Element.new(@contract_class)
          element.instance_eval(&block)
          element.validate!
          resolved_of = element.of_type
          resolved_shape = element.shape
        end

        @params[name] = apply_param_defaults(
          {
            name:,
            type:,
            optional:,
            default:,
            enum: resolved_enum,
            of: resolved_of,
            as:,
            **options,
          },
        )

        if resolved_shape
          @params[name][:shape] = resolved_shape
        elsif block_given? && type != :array
          shape_param_definition = Object.new(@contract_class, action_name: @action_name)
          shape_param_definition.instance_eval(&block)
          @params[name][:shape] = shape_param_definition
        end
      end

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "enum must be a Symbol (reference) or Array (inline values), got #{enum.class}" unless enum.is_a?(Symbol)

        unless @contract_class.enum?(enum)
          raise ArgumentError,
                "Enum :#{enum} not found. Define it using `enum :#{enum}, %w[...]` in definition scope."
        end

        enum
      end
    end
  end
end
