# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining reusable object types.
    #
    # Accessed via `object :name do` in API or contract definitions.
    # Use type methods to define params: {#string}, {#integer}, {#decimal},
    # {#boolean}, {#array}, {#object}, {#union}, {#reference}.
    #
    # @see API::Element Block context for array/variant elements
    # @see Contract::Object Block context for inline objects
    #
    # @example instance_eval style
    #   object :item do
    #     string :description
    #     decimal :amount
    #   end
    #
    # @example yield style
    #   object :item do |object|
    #     object.string :description
    #     object.decimal :amount
    #   end
    class Object < Apiwork::Object
      # @api public
      # Defines a param with explicit type.
      #
      # This is the verbose form. Prefer sugar methods (string, integer, etc.)
      # for static definitions. Use `param` for dynamic param generation.
      #
      # @param name [Symbol]
      #   The param name.
      # @param type [Symbol, nil] (nil) [:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :literal, :number, :object, :string, :time, :union, :uuid]
      #   The param type.
      # @param as [Symbol, nil] (nil)
      #   The target attribute name.
      # @param default [Object, nil] (nil)
      #   The default value.
      # @param deprecated [Boolean] (false)
      #   Whether deprecated. Metadata included in exports.
      # @param description [String, nil] (nil)
      #   The description. Metadata included in exports.
      # @param discriminator [Symbol, nil] (nil)
      #   The discriminator field name. Unions only.
      # @param enum [Array, nil] (nil)
      #   The allowed values.
      # @param example [Object, nil] (nil)
      #   The example value. Metadata included in exports.
      # @param format [Symbol, nil] (nil) [:date, :datetime, :double, :email, :float, :hostname, :int32, :int64, :ipv4, :ipv6, :password, :url, :uuid]
      #   Format hint for exports. Does not change the type, but exports may add validation or documentation based on it.
      #   Valid formats by type: `:decimal`/`:number` (`:double`, `:float`), `:integer` (`:int32`, `:int64`),
      #   `:string` (`:date`, `:datetime`, `:email`, `:hostname`, `:ipv4`, `:ipv6`, `:password`, `:url`, `:uuid`).
      # @param max [Integer, nil] (nil)
      #   The maximum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length.
      # @param min [Integer, nil] (nil)
      #   The minimum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length.
      # @param nullable [Boolean] (false)
      #   Whether the value can be `null`.
      # @param of [Symbol, Hash, nil] (nil)
      #   The element type. Arrays only.
      # @param optional [Boolean] (false)
      #   Whether the param is optional.
      # @param required [Boolean] (false)
      #   Whether the param is required.
      # @param shape [API::Object, API::Union, nil] (nil)
      #   The pre-built shape.
      # @param value [Object, nil] (nil)
      #   The literal value.
      # @yield block for nested structure
      # @yieldparam shape [API::Object, API::Union, API::Element]
      # @return [void]
      #
      # @example Dynamic param generation
      #   param_type = :string
      #   param :title, type: param_type
      #
      # @example Object with block
      #   param :metadata, type: :object do
      #     string :key
      #     string :value
      #   end
      def param(
        name,
        type: nil,
        as: nil,
        default: nil,
        deprecated: false,
        description: nil,
        discriminator: nil,
        enum: nil,
        example: nil,
        format: nil,
        max: nil,
        min: nil,
        nullable: false,
        of: nil,
        optional: false,
        required: false,
        shape: nil,
        value: nil,
        &block
      )
        resolved_of = resolve_of(of, type, &block)
        resolved_shape = type == :array ? nil : (shape || build_shape(type, discriminator, &block))
        discriminator = resolved_of&.discriminator if type == :array

        param_hash = {
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
          type:,
          value:,
          of: resolved_of,
        }
        param_hash[:shape] = resolved_shape if resolved_shape

        @params[name] = (@params[name] || {}).merge(param_hash.compact)
      end

      # @api public
      # Defines an array param with element type.
      #
      # @param name [Symbol]
      #   The param name.
      # @param as [Symbol, nil] (nil)
      #   The target attribute name.
      # @param default [Object, nil] (nil)
      #   The default value.
      # @param deprecated [Boolean] (false)
      #   Whether deprecated. Metadata included in exports.
      # @param description [String, nil] (nil)
      #   The description. Metadata included in exports.
      # @param nullable [Boolean] (false)
      #   Whether the value can be `null`.
      # @param optional [Boolean] (false)
      #   Whether the param is optional.
      # @param required [Boolean] (false)
      #   Whether the param is required.
      # @yield block for defining element type
      # @yieldparam element [API::Element]
      # @return [void]
      #
      # @example instance_eval style
      #   array :tags do
      #     string
      #   end
      #
      # @example yield style
      #   array :tags do |element|
      #     element.string
      #   end
      def array(
        name,
        as: nil,
        default: nil,
        deprecated: false,
        description: nil,
        nullable: false,
        optional: false,
        required: false,
        &block
      )
        raise ArgumentError, 'array requires a block' unless block

        element = Element.new
        block.arity.positive? ? yield(element) : element.instance_eval(&block)
        element.validate!

        param(
          name,
          as:,
          default:,
          deprecated:,
          description:,
          nullable:,
          optional:,
          required:,
          of: element,
          type: :array,
        )
      end

      private

      def resolve_of(of, type, &block)
        return nil unless type == :array

        if block
          element = Element.new
          block.arity.positive? ? yield(element) : element.instance_eval(&block)
          element.validate!
          element
        elsif of.is_a?(Symbol)
          wrap_symbol_in_element(of)
        else
          of
        end
      end

      def wrap_symbol_in_element(type_symbol)
        element = Element.new
        element.of(type_symbol)
        element
      end

      def build_shape(type, discriminator, &block)
        return nil unless block

        case type
        when :object
          shape = Object.new
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
          shape
        when :union
          shape = Union.new(discriminator:)
          block.arity.positive? ? yield(shape) : shape.instance_eval(&block)
          shape
        end
      end
    end
  end
end
