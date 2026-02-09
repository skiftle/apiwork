# frozen_string_literal: true

module Apiwork
  class Object
    attr_reader :merged,
                :params

    def initialize
      @extends = []
      @merged = []
      @params = {}
    end

    # @api public
    # Inherits all properties from another type.
    # Can be called multiple times to inherit from multiple types.
    #
    # @example Single inheritance
    #   object :admin do
    #     extends :user
    #     boolean :superuser
    #   end
    #
    # @example Multiple inheritance
    #   object :employee do
    #     extends :person
    #     extends :contactable
    #     string :employee_id
    #   end
    #
    # @param type_name [Symbol] the type to inherit from
    # @return [Array<Symbol>]
    def extends(type_name = nil)
      @extends << type_name if type_name
      @extends
    end

    # @api public
    # Includes all properties from another type.
    # Can be called multiple times to merge from multiple types.
    #
    # @example
    #   object :admin do
    #     merge! :user
    #     boolean :superuser
    #   end
    #
    # @param type_name [Symbol] the type to merge from
    # @return [Array<Symbol>]
    def merge!(type_name = nil)
      @merged << type_name if type_name
      @merged
    end

    # Merges params from another shape into this one.
    # Used internally by capabilities and document shapes.
    #
    # @param shape [Apiwork::Object] the shape to merge from
    # @return [self]
    def merge_shape!(shape)
      @params.merge!(shape.params)
      self
    end

    # @api public
    # Defines a string.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param enum [Array, Symbol, nil] (nil) allowed values
    # @param example [String, nil] (nil) example value
    # @param format [Symbol, nil] (nil) format hint (:email, :uri, :uuid)
    # @param max [Integer, nil] (nil) maximum length
    # @param min [Integer, nil] (nil) minimum length
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def string(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      enum: nil,
      example: nil,
      format: nil,
      max: nil,
      min: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
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
        required:,
        store:,
        type: :string,
      )
    end

    # @api public
    # Defines an optional string.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param enum [Array, Symbol, nil] (nil) allowed values
    # @param example [String, nil] (nil) example value
    # @param format [Symbol, nil] (nil) format hint (:email, :uri, :uuid)
    # @param max [Integer, nil] (nil) maximum length
    # @param min [Integer, nil] (nil) minimum length
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def string?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      enum: nil,
      example: nil,
      format: nil,
      max: nil,
      min: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        enum:,
        example:,
        format:,
        max:,
        min:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :string,
      )
    end

    # @api public
    # Defines an integer.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param enum [Array, Symbol, nil] (nil) allowed values
    # @param example [Integer, nil] (nil) example value
    # @param max [Integer, nil] (nil) maximum value
    # @param min [Integer, nil] (nil) minimum value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def integer(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      enum: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        enum:,
        example:,
        max:,
        min:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :integer,
      )
    end

    # @api public
    # Defines an optional integer.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param enum [Array, Symbol, nil] (nil) allowed values
    # @param example [Integer, nil] (nil) example value
    # @param max [Integer, nil] (nil) maximum value
    # @param min [Integer, nil] (nil) minimum value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def integer?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      enum: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        enum:,
        example:,
        max:,
        min:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :integer,
      )
    end

    # @api public
    # Defines a decimal.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [Numeric, nil] (nil) example value
    # @param max [Numeric, nil] (nil) maximum value
    # @param min [Numeric, nil] (nil) minimum value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def decimal(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        max:,
        min:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :decimal,
      )
    end

    # @api public
    # Defines an optional decimal.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [Numeric, nil] (nil) example value
    # @param max [Numeric, nil] (nil) maximum value
    # @param min [Numeric, nil] (nil) minimum value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def decimal?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        max:,
        min:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :decimal,
      )
    end

    # @api public
    # Defines a number.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [Numeric, nil] (nil) example value
    # @param max [Numeric, nil] (nil) maximum value
    # @param min [Numeric, nil] (nil) minimum value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def number(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        max:,
        min:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :number,
      )
    end

    # @api public
    # Defines an optional number.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [Numeric, nil] (nil) example value
    # @param max [Numeric, nil] (nil) maximum value
    # @param min [Numeric, nil] (nil) minimum value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def number?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      max: nil,
      min: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        max:,
        min:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :number,
      )
    end

    # @api public
    # Defines a boolean.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [Boolean, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def boolean(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :boolean,
      )
    end

    # @api public
    # Defines an optional boolean.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [Boolean, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def boolean?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :boolean,
      )
    end

    # @api public
    # Defines a datetime.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def datetime(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :datetime,
      )
    end

    # @api public
    # Defines an optional datetime.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def datetime?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :datetime,
      )
    end

    # @api public
    # Defines a date.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def date(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :date,
      )
    end

    # @api public
    # Defines an optional date.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def date?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :date,
      )
    end

    # @api public
    # Defines a UUID.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def uuid(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :uuid,
      )
    end

    # @api public
    # Defines an optional UUID.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def uuid?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :uuid,
      )
    end

    # @api public
    # Defines a time.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def time(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :time,
      )
    end

    # @api public
    # Defines an optional time.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def time?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :time,
      )
    end

    # @api public
    # Defines a binary.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def binary(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :binary,
      )
    end

    # @api public
    # Defines an optional binary.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param example [String, nil] (nil) example value
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def binary?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        example:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :binary,
      )
    end

    # @api public
    # Defines an object.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @yield block defining nested structure
    # @return [void]
    def object(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil,
      &block
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :object,
        &block
      )
    end

    # @api public
    # Defines an optional object.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @yield block defining nested structure
    # @return [void]
    def object?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      required: false,
      store: nil,
      &block
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :object,
        &block
      )
    end

    # @api public
    # Defines an array.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param nullable [Boolean] (false)
    # @param of [Symbol, Hash, nil] (nil) element type
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @yield block defining element type
    # @return [void]
    def array(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      of: nil,
      optional: false,
      required: false,
      store: nil,
      &block
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        of:,
        optional:,
        required:,
        store:,
        type: :array,
        &block
      )
    end

    # @api public
    # Defines an optional array.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param nullable [Boolean] (false)
    # @param of [Symbol, Hash, nil] (nil) element type
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @yield block defining element type
    # @return [void]
    def array?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      of: nil,
      required: false,
      store: nil,
      &block
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        of:,
        required:,
        store:,
        optional: true,
        type: :array,
        &block
      )
    end

    # @api public
    # Defines a union.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param discriminator [Symbol, nil] (nil) discriminator field name
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @yield block defining union variants
    # @return [void]
    def union(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      discriminator: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil,
      &block
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        discriminator:,
        nullable:,
        optional:,
        required:,
        store:,
        type: :union,
        &block
      )
    end

    # @api public
    # Defines an optional union.
    #
    # @param name [Symbol] the name
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param discriminator [Symbol, nil] (nil) discriminator field name
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @yield block defining union variants
    # @return [void]
    def union?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      discriminator: nil,
      nullable: false,
      required: false,
      store: nil,
      &block
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        discriminator:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: :union,
        &block
      )
    end

    # @api public
    # Defines a literal value.
    #
    # @param name [Symbol] the name
    # @param value [Object] the exact value (required)
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param optional [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def literal(
      name,
      value:,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      optional: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        optional:,
        store:,
        value:,
        type: :literal,
      )
    end

    # @api public
    # Defines a reference to a named type.
    #
    # @param name [Symbol] the name
    # @param to [Symbol, nil] (nil) target type name (defaults to name)
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param nullable [Boolean] (false)
    # @param optional [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def reference(
      name,
      to: nil,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      optional: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        optional:,
        required:,
        store:,
        type: to || name,
      )
    end

    # @api public
    # Defines an optional reference to a named type.
    #
    # @param name [Symbol] the name
    # @param to [Symbol, nil] (nil) target type name (defaults to name)
    # @param as [Symbol, nil] (nil) target attribute name
    # @param default [Object, nil] (nil) default value
    # @param deprecated [Boolean] (false)
    # @param description [String, nil] (nil) documentation description
    # @param nullable [Boolean] (false)
    # @param required [Boolean] (false)
    # @param store [Object, nil] (nil) value to persist (replaces received value)
    # @return [void]
    def reference?(
      name,
      to: nil,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      required: false,
      store: nil
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        required:,
        store:,
        optional: true,
        type: to || name,
      )
    end

    def param(name, type: nil, **options, &block)
      raise NotImplementedError, "#{self.class} must implement #param"
    end
  end
end
