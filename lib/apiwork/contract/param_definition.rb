# frozen_string_literal: true

module Apiwork
  module Contract
    # Defines params for query, body, or response.
    #
    # Part of the Adapter DSL. Returned by {RequestDefinition#query},
    # {RequestDefinition#body}, and {ResponseDefinition#body}.
    # Use as a declarative builder - do not rely on internal state.
    #
    # @api public
    class ParamDefinition
      def initialize(contract_class, action_name: nil, wrapped: false)
        @contract_class = contract_class
        @action_name = action_name
        @wrapped = wrapped
        @params = {}
      end

      def wrapped?
        @wrapped
      end

      attr_reader :action_name,
                  :contract_class,
                  :params

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
      # @option options [Boolean] :nullable whether null is allowed
      # @option options [Integer] :min minimum value (numeric) or length (string/array)
      # @option options [Integer] :max maximum value (numeric) or length (string/array)
      # @option options [String] :description field description for docs
      # @option options [Object] :example example value for docs
      # @option options [String] :format format hint (e.g. 'email', 'uri')
      # @option options [Boolean] :deprecated mark field as deprecated
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
      def param(name,
                type: nil,
                optional: nil,
                default: nil,
                enum: nil,
                of: nil,
                as: nil,
                discriminator: nil,
                value: nil,
                visited_types: nil,
                **options,
                &block)
        if type.nil? && (existing_param = @params[name])
          merge_existing_param(name, existing_param, type:, optional:, default:, enum:, of:, as:,
                                                     discriminator:, value:, options:, &block)
          return
        end

        type ||= :string
        raise ArgumentError, 'discriminator can only be used with type: :union' if discriminator && type != :union

        visited_types = visited_types || @visited_types || Set.new

        resolved_enum = resolve_enum_value(enum)

        case type
        when :literal
          define_literal_param(name, value: value, optional: optional || false, default: default, as: as, options: options)
        when :union
          define_union_param(name, discriminator: discriminator, resolved_enum: resolved_enum,
                                   optional: optional || false, default: default, as: as, options: options, &block)
        else
          define_regular_param(name, type: type, resolved_enum: resolved_enum,
                                     optional: optional || false, default: default, of: of, as: as,
                                     visited_types: visited_types, options: options, &block)
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
          param :meta, type: :object, optional: optional, &block
        end
      end

      def validate(data, options = {})
        ParamValidator.new(self).validate(data, options)
      end

      private

      def merge_existing_param(name,
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
                               &block)
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
          shape_param_definition = ParamDefinition.new(@contract_class, action_name: @action_name)
          shape_param_definition.instance_eval(&block)
          @params[name][:shape] = shape_param_definition
        end
      end

      def apply_param_defaults(param_hash)
        {
          optional: false,
          nullable: nil,
          default: nil,
          as: nil,
          enum: nil,
          of: nil,
          shape: nil
        }.merge(param_hash)
      end

      def define_literal_param(name, as:, default:, optional:, options:, value:)
        raise ArgumentError, 'Literal type requires a value parameter' if value.nil? && !options.key?(:value)

        literal_value = value.nil? ? options[:value] : value

        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: :literal,
                                               value: literal_value,
                                               optional: optional,
                                               default: default,
                                               as: as,
                                               **options.except(:value) # Remove :value from options to avoid duplication
                                             })
      end

      def define_union_param(name, as:, default:, discriminator:, optional:, options:, resolved_enum:, &block)
        raise ArgumentError, 'Union type requires a block with variant definitions' unless block_given?

        union_builder = UnionBuilder.new(@contract_class, discriminator: discriminator)
        union_builder.instance_eval(&block)

        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: :union,
                                               optional: optional,
                                               default: default,
                                               as: as,
                                               union: union_builder,
                                               discriminator: discriminator,
                                               enum: resolved_enum, # Store resolved enum (values or reference)
                                               **options
                                             })
      end

      def define_regular_param(name, as:, default:, of:, optional:, options:, resolved_enum:, type:, visited_types:, &block)
        custom_type_block = @contract_class.resolve_custom_type(type)

        if custom_type_block
          expansion_key = [@contract_class.object_id, type]

          custom_type_block = nil if visited_types.include?(expansion_key)
        end

        if custom_type_block
          define_custom_type_param(name, type: type, custom_type_block: custom_type_block,
                                         resolved_enum: resolved_enum, optional: optional,
                                         default: default, of: of, as: as, visited_types: visited_types,
                                         options: options, &block)
        else
          define_standard_param(name, type: type, resolved_enum: resolved_enum,
                                      optional: optional, default: default, of: of, as: as, options: options, &block)
        end
      end

      def define_custom_type_param(name,
                                   type:,
                                   custom_type_block:,
                                   resolved_enum:,
                                   optional:,
                                   default:,
                                   of:,
                                   as:,
                                   visited_types:,
                                   options:,
                                   &block)
        expansion_key = [@contract_class.object_id, type]

        visited_with_current = visited_types.dup.add(expansion_key)

        shape_param_definition = ParamDefinition.new(@contract_class, action_name: @action_name)

        shape_param_definition.instance_variable_set(:@visited_types, visited_with_current)

        custom_type_block.each do |definition_block|
          shape_param_definition.instance_eval(&definition_block)
        end

        shape_param_definition.instance_eval(&block) if block_given?

        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: :object, # Custom types are objects internally
                                               optional: optional,
                                               default: default,
                                               enum: resolved_enum, # Store resolved enum (values or reference)
                                               of: of,
                                               as: as,
                                               custom_type: type, # Track original custom type name
                                               shape: shape_param_definition,
                                               **options
                                             })
      end

      def define_standard_param(name, as:, default:, of:, optional:, options:, resolved_enum:, type:, &block)
        @params[name] = apply_param_defaults({
                                               name: name,
                                               type: type,
                                               optional: optional,
                                               default: default,
                                               enum: resolved_enum, # Store resolved enum (values or reference)
                                               of: of,
                                               as: as,
                                               **options
                                             })

        return unless block_given?

        shape_param_definition = ParamDefinition.new(@contract_class, action_name: @action_name)
        shape_param_definition.instance_eval(&block)
        @params[name][:shape] = shape_param_definition
      end

      def resolve_enum_value(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "enum must be a Symbol (reference) or Array (inline values), got #{enum.class}" unless enum.is_a?(Symbol)

        values = @contract_class.resolve_enum(enum)

        if values
          { ref: enum, values: values }
        else
          raise ArgumentError,
                "Enum :#{enum} not found. Define it using `enum :#{enum}, %w[...]` in contract or definition scope."
        end
      end
    end
  end
end
