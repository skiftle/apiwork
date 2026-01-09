# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Defines an object shape for request/response bodies.
    #
    # Returned by {Request#query}, {Request#body}, and {Response#body}.
    # Use `param` to define fields within the object.
    #
    # @example In a contract action
    #   action :create do
    #     request do
    #       body do
    #         param :title, type: :string
    #         param :amount, type: :decimal
    #       end
    #     end
    #   end
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
      # @yield nested params for :object or :array of objects
      #
      # @example Basic types
      #   param :title, type: :string
      #   param :count, type: :integer, min: 0
      #   param :active, type: :boolean, default: true
      #
      # @example With enum
      #   param :status, enum: %w[draft published archived]
      #   param :role, enum: :user_role  # reference to registered enum
      #
      # @example Nested object
      #   param :address, type: :object do
      #     param :street, type: :string
      #     param :city, type: :string
      #   end
      #
      # @example Array of objects
      #   param :items, type: :array, of: :line_item do
      #     param :product_id, type: :integer
      #     param :quantity, type: :integer, min: 1
      #   end
      #
      # @example Union type
      #   param :payment, type: :union, discriminator: :type do
      #     variant type: :object, tag: 'card' do
      #       param :card_number, type: :string
      #     end
      #   end
      #
      # @see Contract::Union#variant
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
            type:,
            visited_types:,
            optional: optional || false,
            &block
          )
        end
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
      #         param :generated_at, type: :datetime
      #       end
      #     end
      #   end
      #
      # @example Optional meta
      #   response do
      #     body do
      #       meta optional: true do
      #         param :api_version, type: :string
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

            if variant_shape.is_a?(API::Object)
              variant(**variant_data.except(:shape)) do
                variant_shape.params.each do |vp_name, vp_data|
                  param(vp_name, **vp_data.except(:name, :shape))
                end
              end
            else
              variant(**variant_data.except(:shape))
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

      def define_regular_param(name, as:, default:, of:, optional:, options:, resolved_enum:, type:, visited_types:, &block)
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

          if variant_shape.is_a?(API::Object)
            union.variant(**variant_data.except(:shape)) do
              variant_shape.params.each do |vp_name, vp_data|
                param(vp_name, **vp_data.except(:name, :shape))
              end
            end
          else
            union.variant(**variant_data.except(:shape))
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

      def define_standard_param(name, as:, default:, of:, optional:, options:, resolved_enum:, type:, &block)
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

        return unless block_given?

        shape_param_definition = Object.new(@contract_class, action_name: @action_name)
        shape_param_definition.instance_eval(&block)
        @params[name][:shape] = shape_param_definition
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
