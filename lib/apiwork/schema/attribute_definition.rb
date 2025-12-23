# frozen_string_literal: true

module Apiwork
  module Schema
    class AttributeDefinition
      attr_reader :name, :type, :enum, :optional, :empty, :min, :max,
                  :description, :example, :format, :deprecated,
                  :inline_shape, :of

      ALLOWED_FORMATS = {
        string: %i[email uuid uri url date date_time ipv4 ipv6 password hostname],
        integer: %i[int32 int64],
        float: %i[float double],
        decimal: %i[float double],
        number: %i[float double]
      }.freeze

      def initialize(name, schema_class, **options, &block)
        @name = name
        @owner_schema_class = schema_class
        @inline_shape = block
        @of = options[:of]

        options[:type] ||= :object if block

        if schema_class.respond_to?(:model_class) && schema_class.model_class.present?
          @model_class = schema_class.model_class

          begin
            @is_db_column = @model_class.column_names.include?(name.to_s)

            options[:enum] ||= detect_enum_values(name)
            options[:type] ||= detect_type(name) if @is_db_column
            options[:optional] = detect_optional(name) if options[:optional].nil?
            options[:nullable] = detect_nullable(name) if options[:nullable].nil?
          rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
            # Silently skip DB introspection if database is unavailable (e.g., in CI without DB setup)
          end
        end

        options = apply_defaults(options)

        @filterable = options[:filterable]
        @sortable = options[:sortable]
        @writable = case options[:writable]
                    when true then { on: %i[create update] }
                    when false then { on: [] }
                    when Hash then { on: Array(options[:writable][:on] || %i[create update]) }
                    else { on: [] }
                    end
        @encode = options[:encode]
        @decode = options[:decode]
        @empty = options[:empty]
        @nullable = options[:nullable] # Explicit nullable option (overrides DB detection)
        @optional = options[:optional] || false
        @type = options[:type]
        @enum = options[:enum]
        @min = options[:min]
        @max = options[:max]

        @description = options[:description]
        @example = options[:example]
        @format = options[:format]
        @deprecated = options[:deprecated] || false

        validate_min_max_range!
        validate_format!
        validate_empty!
        apply_empty_transformers! if @empty
      end

      def validate!
        validate_attribute_exists!
        validate_column_required_options!
      end

      def filterable?
        @filterable
      end

      def sortable?
        @sortable
      end

      def optional?
        @optional
      end

      def nullable?
        return false if @empty

        @nullable
      end

      def writable?
        @writable[:on].any?
      end

      def writable_for?(action)
        @writable[:on].include?(action)
      end

      def writable_on
        @writable[:on]
      end

      def encode(value)
        validate_enum(value) if enum && value.present?

        apply_transformers(value, @encode)
      end

      def decode(value)
        apply_transformers(value, @decode)
      end

      def schema_class_name
        @schema_class_name ||= @owner_schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
      end

      private

      def apply_defaults(options)
        defaults = {
          filterable: false,
          sortable: false,
          writable: false,
          encode: nil,
          decode: nil,
          empty: false,
          nullable: false,
          optional: false,
          type: :unknown,
          enum: nil,
          description: nil,
          example: nil,
          format: nil,
          deprecated: false
        }

        defaults.merge(options)
      end

      def validate_attribute_exists!
        return if @owner_schema_class.abstract?

        return if @model_class && (@is_db_column || @model_class.instance_methods.include?(@name.to_sym))

        return if @owner_schema_class.instance_methods.include?(@name.to_sym)

        detail = if @model_class
                   "Undefined resource attribute '#{@name}' in #{@owner_schema_class.name}: " \
                   'no DB column, no reader method on model, and no reader method on resource'
                 else
                   "Undefined resource attribute '#{@name}' in #{@owner_schema_class.name}: " \
                   'no reader method on resource'
                 end

        raise ConfigurationError.new(
          code: :invalid_attribute,
          detail: detail,
          path: [@name]
        )
      end

      def validate_enum(value)
        enum_values = enum.is_a?(Hash) ? enum.values : enum

        return if enum_values.map(&:to_s).include?(value.to_s)

        issue = Issue.new(
          layer: :contract,
          code: :value_invalid,
          detail: 'Invalid value',
          path: [name],
          meta: { field: name, expected: enum_values, actual: value }
        )
        raise ContractError, [issue]
      end

      def apply_empty_transformers!
        @encode = Array(@encode).unshift(:nil_to_empty).uniq
        @decode = Array(@decode).push(:blank_to_nil).uniq
      end

      def apply_transformers(value, transformers)
        return value if transformers.nil?

        Array(transformers).reduce(value) do |current_value, transformer|
          if transformer.respond_to?(:call)
            transformer.call(current_value)
          else
            case transformer
            when :nil_to_empty
              current_value.nil? ? '' : current_value
            when :blank_to_nil
              current_value.presence
            else
              current_value
            end
          end
        end
      end

      def detect_enum_values(name)
        return nil unless @model_class&.defined_enums&.key?(name.to_s)

        @model_class.defined_enums[name.to_s].keys
      end

      def detect_type(name)
        raw_type = @model_class.type_for_attribute(name).type
        normalize_db_type(raw_type)
      end

      def normalize_db_type(type)
        case type
        when :text then :string
        when :jsonb then :json
        else type
        end
      end

      def detect_optional(name)
        return false unless @model_class
        return false unless @is_db_column

        column = column_for(name)

        return true if column&.default.present? && @model_class.defined_enums.exclude?(name.to_s)

        column&.null || false
      end

      def detect_nullable(name)
        return false unless @model_class
        return false unless @is_db_column

        column = column_for(name)

        column&.null || false
      end

      def column_for(name)
        @model_class.columns_hash[name.to_s]
      end

      def validate_min_max_range!
        return if @min.nil? || @max.nil?

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

      def validate_column_required_options!
        return if @is_db_column
        return if @owner_schema_class.abstract?

        if filterable?
          raise ConfigurationError.new(
            code: :filterable_requires_column,
            detail: "Attribute #{@name}: filterable requires a database column",
            path: [@name]
          )
        end

        if sortable?
          raise ConfigurationError.new(
            code: :sortable_requires_column,
            detail: "Attribute #{@name}: sortable requires a database column",
            path: [@name]
          )
        end

        return unless writable?

        raise ConfigurationError.new(
          code: :writable_requires_column,
          detail: "Attribute #{@name}: writable requires a database column",
          path: [@name]
        )
      end
    end
  end
end
