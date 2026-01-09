# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Object shape builder with contract context.
    #
    # Wraps {API::Object} and adds contract-specific functionality
    # like enum validation. Used for request/response body definitions.
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
                  :contract_class

      delegate :params, to: :@object

      def initialize(contract_class, action_name: nil)
        @contract_class = contract_class
        @action_name = action_name
        @object = API::Object.new(
          object: -> { Object.new(contract_class, action_name:) },
          union: ->(discriminator) { Union.new(contract_class, discriminator:) },
        )
      end

      # @api public
      # Defines a parameter in this object shape.
      #
      # @param name [Symbol] parameter name
      # @param type [Symbol] data type
      # @param optional [Boolean] whether parameter can be omitted
      # @param as [Symbol] serialize under different name
      # @param default [Object] default value
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation
      # @param discriminator [Symbol] for inline unions
      # @param enum [Array, Symbol] allowed values or enum reference
      # @param example [Object] example value
      # @param format [String] format hint
      # @param max [Integer] maximum value/length
      # @param min [Integer] minimum value/length
      # @param nullable [Boolean] allow null
      # @param of [Symbol] element type for arrays
      # @param value [Object] literal value
      # @yield block for nested object/union shapes
      # @return [void]
      def param(
        name,
        type: nil,
        optional: false,
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
        required: nil,
        value: nil,
        &block
      )
        resolved_enum = resolve_enum(enum)

        @object.param(
          name,
          as:,
          default:,
          deprecated:,
          description:,
          discriminator:,
          example:,
          format:,
          internal:,
          max:,
          min:,
          nullable:,
          of:,
          optional:,
          required:,
          type:,
          value:,
          enum: resolved_enum,
          &block
        )
      end

      # @api public
      # Shorthand for `param :meta, type: :object do ... end`.
      #
      # @param optional [Boolean] whether meta can be omitted
      # @yield block defining meta params
      # @return [void]
      def meta(optional: nil, &block)
        return unless block

        existing_meta = @object.params[:meta]

        if existing_meta && existing_meta[:shape]
          existing_meta[:shape].instance_eval(&block)
        else
          param(:meta, optional:, type: :object, &block)
        end
      end

      def validate(data, current_depth: 0, max_depth: 10, path: [])
        ParamValidator.new(self).validate(data, current_depth:, max_depth:, path:)
      end

      def wrapped?
        false
      end

      private

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        unless @contract_class.enum?(enum)
          raise ArgumentError,
                "Enum :#{enum} not found. Define it using `enum :#{enum}, %w[...]`"
        end

        enum
      end
    end
  end
end
