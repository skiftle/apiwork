# frozen_string_literal: true

module Apiwork
  module Schema
    class AttributeDefinition
      attr_reader :name, :type, :enum, :required, :empty, :min, :max,
                  :description, :example, :format, :deprecated

      ALLOWED_FORMATS = {
        string: %i[email uuid uri url date date_time ipv4 ipv6 password hostname],
        integer: %i[int32 int64],
        float: %i[float double],
        decimal: %i[float double],
        number: %i[float double]
      }.freeze

      def initialize(name, schema_class:, **options)
        @name = name
        @klass = schema_class

        if schema_class.respond_to?(:model_class) && schema_class.model_class.present?
          @model_class = schema_class.model_class

          begin
            @is_db_column = @model_class.column_names.include?(name.to_s)

            options[:enum] ||= detect_enum_values(name)
            options[:type] ||= detect_type(name) if @is_db_column
            options[:required] = detect_required(name) if options[:required].nil?
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
        @required = options[:required] || false
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
        apply_empty_transformers! if @empty
      end

      def validate!
        validate_attribute_exists!
      end

      def filterable?
        @filterable
      end

      def sortable?
        @sortable
      end

      def required?
        @required
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
        validate_enum(value) if enum && !value.nil?

        apply_transformers(value, @encode)
      end

      def decode(value)
        apply_transformers(value, @decode)
      end

      def schema_class_name
        @klass.name.demodulize.underscore.gsub(/_schema$/, '')
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
          required: false,
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
        return if @klass.abstract_class

        return if @model_class && (@is_db_column || @model_class.instance_methods.include?(@name.to_sym))

        return if @klass.instance_methods.include?(@name.to_sym)

        detail = if @model_class
                   "Undefined resource attribute '#{@name}' in #{@klass.name}: " \
                   'no DB column, no reader method on model, and no reader method on resource'
                 else
                   "Undefined resource attribute '#{@name}' in #{@klass.name}: " \
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
        value_str = value.to_s

        return if enum_values.map(&:to_s).include?(value_str)

        issue = Issue.new(
          code: :invalid_value,
          detail: "Must be one of #{enum_values.join(', ')}",
          path: [name]
        )
        raise ContractError, [issue]
      end

      def apply_empty_transformers!
        @encode = Array(@encode).unshift(:nil_to_empty).uniq
        @decode = Array(@decode).push(:blank_to_nil).uniq
      end

      def apply_transformers(value, transformers)
        return value if transformers.nil?

        Array(transformers).reduce(value) do |val, transformer|
          if transformer.respond_to?(:call)
            transformer.call(val)
          else
            case transformer
            when :nil_to_empty
              val.nil? ? '' : val
            when :blank_to_nil
              val.presence
            else
              val
            end
          end
        end
      end

      def detect_enum_values(name)
        return nil unless @model_class&.defined_enums&.key?(name.to_s)

        @model_class.defined_enums[name.to_s].keys
      end

      def detect_type(name)
        @model_class.type_for_attribute(name).type
      end

      def detect_required(name)
        return false unless @model_class
        return false unless @is_db_column

        column = column_for(name)

        return false if column&.default.present? && @model_class.defined_enums.exclude?(name.to_s)

        !column&.null
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

        allowed_formats = ALLOWED_FORMATS[@type]
        format_sym = @format.to_sym

        unless allowed_formats
          raise ConfigurationError,
                "Attribute #{@name}: format option is not supported for type :#{@type}"
        end

        return if allowed_formats.include?(format_sym)

        raise ConfigurationError,
              "Attribute #{@name}: format :#{@format} is not valid for type :#{@type}. " \
              "Allowed formats: #{allowed_formats.join(', ')}"
      end
    end
  end
end
