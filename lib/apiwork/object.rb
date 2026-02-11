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
    # @param type_name [Symbol]
    #   The type to inherit from.
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
    #     merge :user
    #     boolean :superuser
    #   end
    #
    # @param type_name [Symbol]
    #   The type to merge from.
    # @return [Array<Symbol>]
    def merge(type_name = nil)
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
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param enum [Array, Symbol, nil] (nil)
    #   The allowed values.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param format [Symbol, nil] (nil) [:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid]
    #   Format hint for exports. Does not change the type, but exports may add validation or documentation based on it.
    #   Valid formats by type: `:string`.
    # @param max [Integer, nil] (nil)
    #   The maximum length.
    # @param min [Integer, nil] (nil)
    #   The minimum length.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Basic string
    #   string :name
    #
    # @example With format validation
    #   string :email, format: :email
    #
    # @example With length constraints
    #   string :title, min: 1, max: 100
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
      required: false
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
        type: :string,
      )
    end

    # @api public
    # Defines an optional string.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param enum [Array, Symbol, nil] (nil)
    #   The allowed values.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param format [Symbol, nil] (nil) [:date, :datetime, :email, :hostname, :ipv4, :ipv6, :password, :url, :uuid]
    #   Format hint for exports. Does not change the type, but exports may add validation or documentation based on it.
    #   Valid formats by type: `:string`.
    # @param max [Integer, nil] (nil)
    #   The maximum length.
    # @param min [Integer, nil] (nil)
    #   The minimum length.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional string with default
    #   string? :nickname, default: 'Anonymous'
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
      required: false
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
        optional: true,
        type: :string,
      )
    end

    # @api public
    # Defines an integer.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param enum [Array, Symbol, nil] (nil)
    #   The allowed values.
    # @param example [Integer, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param max [Integer, nil] (nil)
    #   The maximum value.
    # @param min [Integer, nil] (nil)
    #   The minimum value.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Basic integer
    #   integer :quantity
    #
    # @example With range constraints
    #   integer :age, min: 0, max: 150
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
      required: false
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
        type: :integer,
      )
    end

    # @api public
    # Defines an optional integer.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param enum [Array, Symbol, nil] (nil)
    #   The allowed values.
    # @param example [Integer, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param max [Integer, nil] (nil)
    #   The maximum value.
    # @param min [Integer, nil] (nil)
    #   The minimum value.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional page number
    #   integer? :page, min: 1, default: 1
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
      required: false
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
        optional: true,
        type: :integer,
      )
    end

    # @api public
    # Defines a decimal.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [Numeric, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param max [Numeric, nil] (nil)
    #   The maximum value.
    # @param min [Numeric, nil] (nil)
    #   The minimum value.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Price with minimum
    #   decimal :amount, min: 0
    #
    # @example Percentage with range
    #   decimal :discount, min: 0, max: 100
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
      required: false
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
        type: :decimal,
      )
    end

    # @api public
    # Defines an optional decimal.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [Numeric, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param max [Numeric, nil] (nil)
    #   The maximum value.
    # @param min [Numeric, nil] (nil)
    #   The minimum value.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional tax rate
    #   decimal? :tax_rate, min: 0, max: 1
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
      required: false
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
        optional: true,
        type: :decimal,
      )
    end

    # @api public
    # Defines a number.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [Numeric, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param max [Numeric, nil] (nil)
    #   The maximum value.
    # @param min [Numeric, nil] (nil)
    #   The minimum value.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Coordinate value
    #   number :latitude, min: -90, max: 90
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
      required: false
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
        type: :number,
      )
    end

    # @api public
    # Defines an optional number.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [Numeric, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param max [Numeric, nil] (nil)
    #   The maximum value.
    # @param min [Numeric, nil] (nil)
    #   The minimum value.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional score
    #   number? :score, min: 0, max: 100
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
      required: false
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
        optional: true,
        type: :number,
      )
    end

    # @api public
    # Defines a boolean.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [Boolean, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Active flag
    #   boolean :active
    #
    # @example With default
    #   boolean :published, default: false
    def boolean(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: :boolean,
      )
    end

    # @api public
    # Defines an optional boolean.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [Boolean, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional notification flag
    #   boolean? :notify, default: true
    def boolean?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false
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
        optional: true,
        type: :boolean,
      )
    end

    # @api public
    # Defines a datetime.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Timestamp
    #   datetime :created_at
    def datetime(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: :datetime,
      )
    end

    # @api public
    # Defines an optional datetime.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional deletion timestamp
    #   datetime? :deleted_at
    def datetime?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false
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
        optional: true,
        type: :datetime,
      )
    end

    # @api public
    # Defines a date.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Birth date
    #   date :birth_date
    def date(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: :date,
      )
    end

    # @api public
    # Defines an optional date.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional expiry date
    #   date? :expires_on
    def date?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false
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
        optional: true,
        type: :date,
      )
    end

    # @api public
    # Defines a UUID.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Primary key
    #   uuid :id
    def uuid(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: :uuid,
      )
    end

    # @api public
    # Defines an optional UUID.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional parent reference
    #   uuid? :parent_id
    def uuid?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false
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
        optional: true,
        type: :uuid,
      )
    end

    # @api public
    # Defines a time.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Opening time
    #   time :opens_at
    def time(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: :time,
      )
    end

    # @api public
    # Defines an optional time.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional closing time
    #   time? :closes_at
    def time?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false
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
        optional: true,
        type: :time,
      )
    end

    # @api public
    # Defines a binary.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example File content
    #   binary :content
    def binary(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: :binary,
      )
    end

    # @api public
    # Defines an optional binary.
    #
    # @param name [Symbol]
    #   The name.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param example [String, nil] (nil)
    #   The example value. Metadata included in exports.
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional attachment
    #   binary? :attachment
    def binary?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      example: nil,
      nullable: false,
      required: false
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
        optional: true,
        type: :binary,
      )
    end

    # @api public
    # Defines an object.
    #
    # @param name [Symbol]
    #   The name.
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
    # @yield block defining nested structure
    # @return [void]
    #
    # @example Nested address object
    #   object :address do
    #     string :street
    #     string :city
    #     string :country
    #   end
    def object(
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
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        optional:,
        required:,
        type: :object,
        &block
      )
    end

    # @api public
    # Defines an optional object.
    #
    # @param name [Symbol]
    #   The name.
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
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @yield block defining nested structure
    # @return [void]
    #
    # @example Optional metadata
    #   object? :metadata do
    #     string :key
    #     string :value
    #   end
    def object?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      required: false,
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
        optional: true,
        type: :object,
        &block
      )
    end

    # @api public
    # Defines an array.
    #
    # @param name [Symbol]
    #   The name.
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
    # @param of [Symbol, Hash, nil] (nil)
    #   The element type. Arrays only.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @yield block defining element type
    # @return [void]
    #
    # @example Array of strings
    #   array :tags do
    #     string
    #   end
    #
    # @example Array of objects
    #   array :items do
    #     object do
    #       string :name
    #       decimal :price
    #     end
    #   end
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
        type: :array,
        &block
      )
    end

    # @api public
    # Defines an optional array.
    #
    # @param name [Symbol]
    #   The name.
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
    # @param of [Symbol, Hash, nil] (nil)
    #   The element type. Arrays only.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @yield block defining element type
    # @return [void]
    #
    # @example Optional array of labels
    #   array? :labels do
    #     string
    #   end
    def array?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      of: nil,
      required: false,
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
        optional: true,
        type: :array,
        &block
      )
    end

    # @api public
    # Defines a union.
    #
    # @param name [Symbol]
    #   The name.
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
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @yield block defining union variants
    # @return [void]
    #
    # @example Payment method union
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
        type: :union,
        &block
      )
    end

    # @api public
    # Defines an optional union.
    #
    # @param name [Symbol]
    #   The name.
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
    # @param nullable [Boolean] (false)
    #   Whether the value can be `null`.
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @yield block defining union variants
    # @return [void]
    #
    # @example Optional notification preference
    #   union? :notification, discriminator: :type do
    #     variant tag: 'email' do
    #       object do
    #         string :address
    #       end
    #     end
    #     variant tag: 'sms' do
    #       object do
    #         string :phone
    #       end
    #     end
    #   end
    def union?(
      name,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      discriminator: nil,
      nullable: false,
      required: false,
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
        optional: true,
        type: :union,
        &block
      )
    end

    # @api public
    # Defines a literal value.
    #
    # @param name [Symbol]
    #   The name.
    # @param value [Object]
    #   The exact value.
    # @param as [Symbol, nil] (nil)
    #   The target attribute name.
    # @param default [Object, nil] (nil)
    #   The default value.
    # @param deprecated [Boolean] (false)
    #   Whether deprecated. Metadata included in exports.
    # @param description [String, nil] (nil)
    #   The description. Metadata included in exports.
    # @param optional [Boolean] (false)
    #   Whether the param is optional.
    # @return [void]
    #
    # @example Fixed version number
    #   literal :version, value: '1.0'
    def literal(
      name,
      value:,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      optional: false
    )
      param(
        name,
        as:,
        default:,
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
    # @param name [Symbol]
    #   The name.
    # @param to [Symbol, nil] (nil)
    #   The target type name. Defaults to name.
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
    # @return [void]
    #
    # @example Reference to customer type
    #   reference :customer
    #
    # @example Reference with different field name
    #   reference :billing_address, to: :address
    def reference(
      name,
      to: nil,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      optional: false,
      required: false
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
        type: to || name,
      )
    end

    # @api public
    # Defines an optional reference to a named type.
    #
    # @param name [Symbol]
    #   The name.
    # @param to [Symbol, nil] (nil)
    #   The target type name. Defaults to name.
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
    # @param required [Boolean] (false)
    #   Whether the param is required.
    # @return [void]
    #
    # @example Optional shipping address
    #   reference? :shipping_address, to: :address
    def reference?(
      name,
      to: nil,
      as: nil,
      default: nil,
      deprecated: false,
      description: nil,
      nullable: false,
      required: false
    )
      param(
        name,
        as:,
        default:,
        deprecated:,
        description:,
        nullable:,
        required:,
        optional: true,
        type: to || name,
      )
    end

    def param(name, type: nil, **options, &block)
      raise NotImplementedError, "#{self.class} must implement #param"
    end
  end
end
