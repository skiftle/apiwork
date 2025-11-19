# frozen_string_literal: true

module Apiwork
  module Schema
    class AttributeDefinition
      attr_reader :name, :type, :enum, :required, :empty, :min, :max

      def initialize(name, schema_class:, **options)
        @name = name
        @klass = schema_class

        # Model introspection (if model exists)
        if schema_class.respond_to?(:model_class) && schema_class.model_class.present?
          @model_class = schema_class.model_class

          # Only introspect if DB is connected and table exists
          begin
            @is_db_column = @model_class.column_names.include?(name.to_s)

            # Auto-detect from DB
            options[:enum] ||= detect_enum_values(name)
            options[:type] ||= detect_type(name) if @is_db_column
            options[:required] = detect_required(name) if options[:required].nil?
            options[:nullable] = detect_nullable(name) if options[:nullable].nil?
          rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
            # DB not available or table doesn't exist - skip introspection
          end
        end

        # Normalize and apply defaults
        options = apply_defaults(options)

        # Store all options
        @filterable = options[:filterable]
        @sortable = options[:sortable]
        @writable = case options[:writable]
                    when true then { on: %i[create update] }
                    when false then { on: [] }
                    when Hash then { on: Array(options[:writable][:on] || %i[create update]) }
                    else { on: [] }
                    end
        @serialize = options[:serialize]
        @deserialize = options[:deserialize]
        @empty = options[:empty]
        @nullable = options[:nullable] # Explicit nullable option (overrides DB detection)
        @required = options[:required] || false
        @type = options[:type]
        @enum = options[:enum]
        @min = options[:min]
        @max = options[:max]

        validate_min_max_range!
        apply_empty_transformers! if @empty
      end

      # Validate that this attribute exists (lazy - called explicitly, not during class loading)
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
        # empty always overrides to false
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

      def serialize(value)
        # Validate enum values before serialization
        validate_enum(value) if enum && !value.nil?

        apply_transformers(value, @serialize)
      end

      def deserialize(value)
        apply_transformers(value, @deserialize)
      end

      private

      def apply_defaults(options)
        defaults = {
          filterable: false,
          sortable: false,
          writable: false,
          serialize: nil,
          deserialize: nil,
          empty: false,
          nullable: false,
          required: false,
          type: nil,
          enum: nil
        }

        defaults.merge(options)
      end

      def validate_attribute_exists!
        return if @klass.abstract_class

        # Check model first (DB column or model method) if model exists
        return if @model_class && (@is_db_column || @model_class.instance_methods.include?(@name.to_sym))

        # Check resource methods
        return if @klass.instance_methods.include?(@name.to_sym)

        # Attribute not found
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
          message: "Must be one of #{enum_values.join(', ')}",
          path: [name]
        )
        raise ContractError, [issue]
      end

      def apply_empty_transformers!
        @serialize = Array(@serialize).unshift(:nil_to_empty).uniq
        @deserialize = Array(@deserialize).push(:blank_to_nil).uniq
      end

      def apply_transformers(value, transformers)
        return value if transformers.nil?

        Array(transformers).reduce(value) do |val, transformer|
          if transformer.respond_to?(:call)
            transformer.call(val)
          else
            # Handle built-in symbol transformers
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

      # Model introspection methods

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

        # Column with default not required (DB handles it)
        # Exception: Enum fields with defaults still required
        return false if column&.default.present? && @model_class.defined_enums.exclude?(name.to_s)

        # null: false constraint means required
        !column&.null
      end

      def detect_nullable(name)
        return false unless @model_class
        return false unless @is_db_column

        column = column_for(name)

        # Return true if column allows NULL, false if NOT NULL
        column&.null || false
      end

      def column_for(name)
        @model_class.columns_hash[name.to_s]
      end

      # Validate that min <= max if both are set
      def validate_min_max_range!
        return if @min.nil? || @max.nil?

        return unless @min > @max

        raise ConfigurationError,
              "Attribute #{@name}: min (#{@min}) cannot be greater than max (#{@max})"
      end
    end
  end
end
