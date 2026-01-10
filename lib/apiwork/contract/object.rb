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
      # Defines a parameter/field in a request or response body.
      #
      # @param name [Symbol] field name
      # @param type [Symbol] data type (:string, :integer, :boolean, :datetime, :date,
      #   :uuid, :object, :array, :decimal, :float, :literal, :union, or custom type)
      # @param optional [Boolean] whether field can be omitted (default: false)
      # @param default [Object] value when field is nil
      # @param enum [Array, Symbol] allowed values, or reference to registered enum
      # @param of [Symbol] element type for :array
      # @param as [Symbol] serialize field under different name
      # @param discriminator [Symbol] discriminator field for :union type
      # @param value [Object] exact value for :literal type
      # @param deprecated [Boolean] mark field as deprecated
      # @param description [String] field description for docs
      # @param example [Object] example value for docs
      # @param format [String] format hint (e.g. 'email', 'uri')
      # @param max [Integer] maximum value (numeric) or length (string/array)
      # @param min [Integer] minimum value (numeric) or length (string/array)
      # @param nullable [Boolean] whether null is allowed
      # @param required [Boolean] alias for optional: false (for readability)
      # @return [void]
      # @see Contract::Object
      # @see Contract::Union
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
        optional: nil,
        required: nil,
        shape: nil,
        type: nil,
        value: nil,
        internal: {},
        &block
      )
        visited_types = internal[:visited_types]
        decoder = internal[:decoder]
        sti_mapping = internal[:sti_mapping]
        type_contract_class = internal[:type_contract_class]

        options = {
          decoder:,
          deprecated:,
          description:,
          example:,
          format:,
          internal:,
          max:,
          min:,
          nullable:,
          required:,
          sti_mapping:,
          type_contract_class:,
        }.compact
        if type.nil? && (existing_param = @params[name])
          merge_existing_param(
            name,
            existing_param,
            as:,
            default:,
            discriminator:,
            enum:,
            of:,
            optional:,
            options:,
            type:,
            value:,
            &block
          )
          return
        end

        raise ArgumentError, 'discriminator can only be used with type: :union' if discriminator && type != :union

        visited_types ||= @visited_types
        visited_types ||= Set.new

        resolved_enum = resolve_enum_value(enum)

        case type
        when :literal
          define_literal_param(name, as:, default:, options:, value:, optional: optional || false)
        when :union
          define_union_param(
            name,
            as:,
            default:,
            discriminator:,
            options:,
            resolved_enum:,
            optional: optional || false,
            &block
          )
        else
          define_regular_param(
            name,
            as:,
            default:,
            of:,
            options:,
            resolved_enum:,
            shape:,
            type:,
            visited_types:,
            optional: optional || false,
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
          type: :string,
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
          default:,
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
          default:,
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
        default: nil,
        deprecated: nil,
        description: nil,
        example: nil,
        nullable: nil,
        optional: false
      )
        param(
          name,
          default:,
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
      # @param default [Float] default value
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
          default:,
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
          default:,
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
          default:,
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
          default:,
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
          default:,
          deprecated:,
          description:,
          nullable:,
          optional:,
          discriminator: element.discriminator,
          of: element.of_type,
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
          deprecated:,
          description:,
          discriminator:,
          nullable:,
          optional:,
          type: :union,
          &block
        )
      end

      # @api public
      # Shorthand for `param :meta, type: :object do ... end`.
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
      def meta(optional: nil, &block)
        return unless block

        existing_meta = @params[:meta]

        if existing_meta && existing_meta[:shape]
          existing_meta[:shape].instance_eval(&block)
        else
          param :meta, optional:, type: :object, &block
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

          if nested_shape.is_a?(API::Object)
            copy_nested_object_param(target_param, param_name, param_data, nested_shape)
          elsif nested_shape.is_a?(API::Union)
            copy_nested_union_param(target_param, param_name, param_data, nested_shape)
          else
            target_param.param(param_name, **param_data.except(:name, :shape))
          end
        end
      end

      private

      def copy_nested_object_param(target_param, param_name, param_data, nested_shape)
        target_param.param(
          param_name,
          **param_data.except(:name, :shape),
        ) do
          nested_shape.params.each do |nested_name, nested_data|
            param(nested_name, **nested_data.except(:name, :shape))
          end
        end
      end

      def copy_nested_union_param(target_param, param_name, param_data, nested_shape)
        target_param.param(
          param_name,
          **param_data.except(:name, :shape),
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
                    param(vp_name, **vp_data.except(:name, :shape))
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

      def merge_existing_param(
        name,
        existing_param,
        type:,
        optional:,
        default:,
        enum:,
        of:,
        as:,
        discriminator:,
        value:,
        options:,
        &block
      )
        resolved_enum = enum ? resolve_enum_value(enum) : nil

        merged_param = existing_param.merge(options.compact)
        merged_param[:type] = type if type
        merged_param[:optional] = optional unless optional.nil?
        merged_param[:default] = default if default
        merged_param[:enum] = resolved_enum if resolved_enum
        merged_param[:of] = of if of
        merged_param[:as] = as if as
        merged_param[:discriminator] = discriminator if discriminator
        merged_param[:value] = value if value

        @params[name] = merged_param

        return unless block

        if existing_param[:union]
          existing_param[:union].instance_eval(&block)
        elsif existing_param[:shape]
          existing_param[:shape].instance_eval(&block)
        else
          shape_param_definition = Object.new(@contract_class, action_name: @action_name)
          shape_param_definition.instance_eval(&block)
          @params[name][:shape] = shape_param_definition
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

      def define_literal_param(name, as:, default:, optional:, options:, value:)
        raise ArgumentError, 'Literal type requires a value parameter' if value.nil? && !options.key?(:value)

        literal_value = value.nil? ? options[:value] : value

        @params[name] = apply_param_defaults(
          {
            name:,
            type: :literal,
            value: literal_value,
            optional:,
            default:,
            as:,
            **options.except(:value),
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
                  param(vp_name, **vp_data.except(:name, :shape))
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
        @params[name] = apply_param_defaults(
          {
            name:,
            type:,
            optional:,
            default:,
            enum: resolved_enum,
            of:,
            as:,
            **options,
          },
        )

        if shape
          @params[name][:shape] = shape
        elsif block_given?
          shape_param_definition = Object.new(@contract_class, action_name: @action_name)
          shape_param_definition.instance_eval(&block)
          @params[name][:shape] = shape_param_definition
        end
      end

      def resolve_enum_value(enum)
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
