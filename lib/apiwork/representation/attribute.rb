# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Represents an attribute defined on a representation.
    #
    # Attributes map to model columns and define serialization behavior.
    # Used by adapters to build contracts and serialize records.
    #
    # @example
    #   attribute = InvoiceRepresentation.attributes[:title]
    #   attribute.name       # => :title
    #   attribute.type       # => :string
    #   attribute.filterable? # => true
    class Attribute
      ALLOWED_FORMATS = {
        decimal: %i[float double],
        integer: %i[int32 int64],
        number: %i[float double],
        string: %i[email uuid url date datetime ipv4 ipv6 password hostname],
      }.freeze

      # @api public
      # The description for this attribute.
      #
      # @return [String, nil]
      attr_reader :description

      # @api public
      # The enum for this attribute.
      #
      # @return [Array<Object>, nil]
      attr_reader :enum

      # @api public
      # The example for this attribute.
      #
      # @return [Object, nil]
      attr_reader :example

      # @api public
      # The format for this attribute.
      #
      # @return [Symbol, nil]
      attr_reader :format

      # @api public
      # The maximum for this attribute.
      #
      # @return [Integer, nil]
      attr_reader :max

      # @api public
      # The minimum for this attribute.
      #
      # @return [Integer, nil]
      attr_reader :min

      # @api public
      # The name for this attribute.
      #
      # @return [Symbol]
      attr_reader :name

      # @api public
      # The of for this attribute.
      #
      # @return [Symbol, nil]
      attr_reader :of

      # @api public
      # The preload for this attribute.
      #
      # @return [Symbol, Array, Hash, nil]
      attr_reader :preload

      # @api public
      # The type for this attribute.
      #
      # @return [Symbol]
      attr_reader :type

      attr_reader :element,
                  :empty,
                  :optional

      def initialize(
        name,
        owner_representation_class,
        decode: nil,
        deprecated: false,
        description: nil,
        empty: false,
        encode: nil,
        enum: nil,
        example: nil,
        filterable: false,
        format: nil,
        max: nil,
        min: nil,
        nullable: nil,
        optional: nil,
        preload: nil,
        sortable: false,
        type: nil,
        writable: false,
        &block
      )
        @name = name
        @owner_representation_class = owner_representation_class
        @of = nil

        if block
          element = Element.new
          block.arity.positive? ? yield(element) : element.instance_eval(&block)
          element.validate!
          @element = element
          type = element.type
          @of = element.of_type if element.type == :array
        end

        if owner_representation_class.model_class.present?
          @model_class = owner_representation_class.model_class

          begin
            @db_column = @model_class.column_names.include?(name.to_s)

            enum ||= detect_enum_values(name)
            type ||= detect_type(name) if @db_column
            optional = detect_optional(name) if optional.nil?
            nullable = detect_nullable(name) if nullable.nil?
          rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
            @db_column = false
          end
        end

        optional = false if optional.nil?
        nullable = false if nullable.nil?

        @filterable = filterable
        @preload = preload
        @sortable = sortable
        @writable = normalize_writable(writable)
        @encode = encode
        @decode = decode
        @empty = empty
        @nullable = nullable
        @optional = optional
        @type = type || :unknown
        @enum = enum
        @min = min
        @max = max
        @description = description
        @example = example
        @format = format
        @deprecated = deprecated

        validate_min_max_range!
        validate_format!
        validate_empty!
      end

      # @api public
      # Whether this attribute is deprecated.
      #
      # @return [Boolean]
      def deprecated?
        @deprecated
      end

      # @api public
      # Whether this attribute is filterable.
      #
      # @return [Boolean]
      def filterable?
        @filterable
      end

      # @api public
      # Whether this attribute is sortable.
      #
      # @return [Boolean]
      def sortable?
        @sortable
      end

      # @api public
      # Whether this attribute is optional.
      #
      # @return [Boolean]
      def optional?
        @optional
      end

      # @api public
      # Whether this attribute is nullable.
      #
      # @return [Boolean]
      def nullable?
        return false if @empty

        @nullable
      end

      # @api public
      # Whether this attribute is writable.
      #
      # @return [Boolean]
      # @see #writable_for?
      def writable?
        @writable[:on].any?
      end

      # @api public
      # Whether this attribute is writable for the given action.
      #
      # @param action [Symbol] [:create, :update]
      #   The action.
      # @return [Boolean]
      # @see #writable?
      def writable_for?(action)
        @writable[:on].include?(action)
      end

      def encode(value)
        validate_enum(value) if enum && value.present?

        result = @empty && value.nil? ? '' : value
        @encode ? @encode.call(result) : result
      end

      def decode(value)
        result = @decode ? @decode.call(value) : value
        @empty ? result.presence : result
      end

      def representation_class_name
        @representation_class_name ||= @owner_representation_class
          .name
          .demodulize
          .delete_suffix('Representation')
          .underscore
      end

      private

      def normalize_writable(value)
        case value
        when true  then { on: %i[create update] }
        when false then { on: [] }
        when Hash  then { on: Array(value[:on] || %i[create update]) }
        else            { on: [] }
        end
      end

      def validate_enum(value)
        return if enum.map(&:to_s).include?(value.to_s)

        issue = Issue.new(
          :value_invalid,
          'Invalid value',
          meta: {
            actual: value,
            expected: enum,
            field: name,
          },
          path: [name],
        )
        raise ContractError, [issue]
      end

      def detect_enum_values(name)
        return nil unless @model_class.defined_enums.key?(name.to_s)

        @model_class.defined_enums[name.to_s].keys
      end

      def detect_type(name)
        raw_type = @model_class.type_for_attribute(name).type
        normalize_db_type(raw_type)
      end

      def normalize_db_type(type)
        case type
        when :text then :string
        when :jsonb, :json then :unknown
        when :float then :number
        else type
        end
      end

      def detect_optional(name)
        return false unless @model_class
        return false unless db_column?

        column = column_for(name)
        return false unless column

        return true if column.default.present?

        column.null
      end

      def detect_nullable(name)
        return false unless @model_class
        return false unless db_column?

        column = column_for(name)
        return false unless column

        column.null
      end

      def column_for(name)
        @model_class.columns_hash[name.to_s]
      end

      def db_column?
        @db_column
      end

      def validate_min_max_range!
        return if @min.nil?
        return if @max.nil?
        return unless @min > @max

        raise ConfigurationError,
              "Attribute #{@name}: min (#{@min}) cannot be greater than max (#{@max})"
      end

      def validate_format!
        return if @format.nil?
        return if @type == :unknown

        allowed_formats = ALLOWED_FORMATS[@type]

        unless allowed_formats
          raise ConfigurationError,
                "Attribute #{@name}: format option is not supported for type :#{@type}"
        end

        return if allowed_formats.include?(@format.to_sym)

        raise ConfigurationError,
              "Attribute #{@name}: format :#{@format} is not valid for type :#{@type}. " \
              "Allowed formats: #{allowed_formats.join(', ')}"
      end

      def validate_empty!
        return unless @empty
        return if @type == :unknown
        return if @type == :string

        raise ConfigurationError,
              "Attribute #{@name}: empty option is only supported for type :string"
      end
    end
  end
end
