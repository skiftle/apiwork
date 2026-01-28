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
    class Object < Apiwork::Object
      attr_reader :action_name,
                  :contract_class,
                  :visited_types

      def initialize(contract_class, action_name: nil, visited_types: nil, wrapped: false)
        super()
        @contract_class = contract_class
        @action_name = action_name
        @wrapped = wrapped
        @visited_types = visited_types
      end

      # @api public
      # Defines a field with explicit type.
      #
      # This is the verbose form. Prefer sugar methods (string, integer, etc.)
      # for static definitions. Use `param` for dynamic field generation.
      #
      # @param name [Symbol] field name
      # @param type [Symbol, nil] field type
      # @param as [Symbol, nil] target attribute name
      # @param default [Object, nil] default value
      # @param deprecated [Boolean, nil] mark as deprecated
      # @param description [String, nil] documentation description
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param enum [Array, Symbol, nil] allowed values or enum reference
      # @param example [Object, nil] example value
      # @param format [Symbol, nil] format hint
      # @param max [Integer, nil] maximum value or length
      # @param min [Integer, nil] minimum value or length
      # @param nullable [Boolean, nil] whether null is allowed
      # @param of [Symbol, Hash, nil] element type (arrays only)
      # @param optional [Boolean, nil] whether field can be omitted
      # @param required [Boolean, nil] explicit required flag
      # @param shape [Contract::Object, Contract::Union, nil] pre-built shape
      # @param store [Boolean, nil] whether to persist
      # @param transform [Proc, nil] value transformation lambda
      # @param value [Object, nil] literal value
      # @yield block for nested structure (instance_eval style)
      # @yieldparam builder [Contract::Object, Contract::Union, Contract::Element] the builder (yield style)
      # @return [void]
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
        max: nil,
        min: nil,
        nullable: nil,
        of: nil,
        optional: nil,
        required: nil,
        shape: nil,
        store: nil,
        transform: nil,
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
          transform:,
        }

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

      # Override array to use Contract::Element
      def array(name, **options, &block)
        raise ArgumentError, 'array requires a block' unless block

        element = Element.new(@contract_class)
        block.arity.positive? ? yield(element) : element.instance_eval(&block)
        element.validate!

        param(
          name,
          of: {
            enum: element.enum,
            format: element.format,
            max: element.max,
            min: element.min,
            type: element.of_type,
          }.compact,
          shape: element.shape,
          type: :array,
          **options,
        )
      end

      # @api public
      # Shorthand for `object :meta do ... end`.
      #
      # Use for response data that doesn't belong to the resource itself.
      #
      # @param optional [Boolean] whether meta can be omitted (default: false)
      # @yield block defining meta params (instance_eval style)
      # @yieldparam builder [Contract::Object] the builder (yield style)
      def meta(optional: nil, &block)
        return unless block

        existing_meta = @params[:meta]

        if existing_meta && existing_meta[:shape]
          shape = existing_meta[:shape]
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
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

        type_definition.params&.each do |param_name, param_options|
          nested_shape = param_options[:shape]

          if param_options[:type] == :array && nested_shape.is_a?(Apiwork::API::Object)
            target_param.param(param_name, **param_options.except(:name))
          elsif nested_shape.is_a?(API::Object)
            copy_nested_object_param(target_param, param_name, param_options, nested_shape)
          elsif nested_shape.is_a?(API::Union)
            copy_nested_union_param(target_param, param_name, param_options, nested_shape)
          else
            target_param.param(param_name, **param_options.except(:name, :shape))
          end
        end
      end

      private

      def copy_nested_object_param(target_param, param_name, param_options, nested_shape)
        target_param.param(
          param_name,
          type: param_options[:type],
          **param_options.except(:name, :type, :shape),
        ) do
          nested_shape.params.each do |nested_name, nested_param_options|
            param(nested_name, **nested_param_options.except(:name, :shape))
          end
        end
      end

      def copy_nested_union_param(target_param, param_name, param_options, nested_shape)
        target_param.param(
          param_name,
          type: param_options[:type],
          **param_options.except(:name, :type, :shape),
        ) do
          nested_shape.variants.each do |variant|
            variant_shape = variant[:shape]
            variant_type = variant[:type]
            variant_tag = variant[:tag]
            variant_custom_type = variant[:custom_type]

            if variant_shape.is_a?(API::Object)
              variant tag: variant_tag do
                object do
                  variant_shape.params.each do |name, param_options|
                    param(name, **param_options.except(:name, :shape))
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

      def define_literal_param(name, as:, default:, deprecated:, description:, optional:, store:, value:)
        raise ArgumentError, 'Literal type requires a value parameter' if value.nil?

        @params[name] = (@params[name] || {}).merge(
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
          }.compact,
        )
      end

      def define_union_param(name, as:, default:, discriminator:, optional:, options:, resolved_enum:, &block)
        raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

        union = Union.new(@contract_class, discriminator:)
        block.arity.positive? ? yield(union) : union.instance_eval(&block)

        @params[name] = (@params[name] || {}).merge(
          {
            as:,
            default:,
            discriminator:,
            enum: resolved_enum,
            name:,
            optional:,
            type: :union,
            union:,
            **options,
          }.compact,
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

        type_definition.variants.each do |variant|
          variant_shape = variant[:shape]
          variant_type = variant[:type]
          variant_tag = variant[:tag]
          variant_custom_type = variant[:custom_type]

          if variant_shape.is_a?(API::Object)
            union.variant tag: variant_tag do
              object do
                variant_shape.params.each do |name, param_options|
                  param(name, **param_options.except(:name, :shape))
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

        @params[name] = (@params[name] || {}).merge(
          {
            as:,
            custom_type: type,
            default:,
            discriminator: type_definition.discriminator,
            enum: resolved_enum,
            name:,
            optional:,
            type: :union,
            union:,
            **options,
          }.compact,
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
        shape = Object.new(
          @contract_class,
          action_name: @action_name,
          visited_types: visited_types.dup.add([@contract_class.object_id, type]),
        )

        copy_type_definition_params(type_definition, shape)

        if block_given?
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
        end

        @params[name] = (@params[name] || {}).merge(
          {
            as:,
            custom_type: type,
            default:,
            enum: resolved_enum,
            name:,
            of:,
            optional:,
            shape:,
            type: :object,
            **options,
          }.compact,
        )
      end

      def define_standard_param(name, as:, default:, of:, optional:, options:, resolved_enum:, shape:, type:, &block)
        resolved_of = of
        resolved_shape = shape

        if block_given? && type == :array
          element = Element.new(@contract_class)
          block.arity.positive? ? yield(element) : element.instance_eval(&block)
          element.validate!
          resolved_of = element.of_type
          resolved_shape = element.shape
        end

        @params[name] = (@params[name] || {}).merge(
          {
            as:,
            default:,
            enum: resolved_enum,
            name:,
            of: resolved_of,
            optional:,
            type:,
            **options,
          }.compact,
        )

        if resolved_shape
          @params[name][:shape] = resolved_shape
        elsif block_given? && type != :array
          nested_shape = Object.new(@contract_class, action_name: @action_name)
          block.arity.positive? ? yield(nested_shape) : nested_shape.instance_eval(&block)
          @params[name][:shape] = nested_shape
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
