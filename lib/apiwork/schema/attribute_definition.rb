# frozen_string_literal: true

module Apiwork
  module Schema
    class AttributeDefinition
      attr_reader :name, :type, :enum, :required, :null_to_empty

      def initialize(name, klass:, **options)
        @name = name
        @klass = klass

        # Model introspection (if model exists)
        if klass.respond_to?(:model_class) && klass.model_class.present?
          @model_class = klass.model_class

          # Only introspect if DB is connected and table exists
          begin
            @is_db_column = @model_class.column_names.include?(name.to_s)

            # Auto-detect from DB
            options[:enum] ||= detect_enum_values(name)
            options[:type] ||= detect_type(name) if @is_db_column
            options[:required] = detect_required(name) if options[:required].nil? && @is_db_column
            options[:nullable] = detect_nullable(name) if options[:nullable].nil? && @is_db_column
          rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
            # DB not available or table doesn't exist - skip introspection
          end
        end

        # Normalize and apply defaults
        options = apply_defaults(options)

        # Store all options
        @filterable = options[:filterable]
        @sortable = options[:sortable]
        @writable = normalize_writable(options[:writable])
        @serialize = options[:serialize]
        @deserialize = options[:deserialize]
        @null_to_empty = options[:null_to_empty]
        @nullable = options[:nullable]  # Explicit nullable option (overrides DB detection)
        @required = options[:required] || false
        @type = options[:type]
        @enum = options[:enum]

        # Validate early - after all instance variables are set
        validate_attribute_exists!

        # Validate and apply null_to_empty
        validate_null_to_empty!
        apply_null_to_empty_transformers! if @null_to_empty
      end

      def filterable?(context = nil)
        return @filterable.call(context) if @filterable.is_a?(Proc)

        @filterable
      end

      def sortable?(context = nil)
        return @sortable.call(context) if @sortable.is_a?(Proc)

        @sortable
      end

      def required?
        @required
      end

      def nullable?
        # null_to_empty ALWAYS overrides to false
        # (transformation happens in serialize/deserialize, so frontend never sees null)
        return false if @null_to_empty

        # Otherwise use the stored value (from explicit config or DB detection)
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
        apply_transformers(value, @serialize)
      end

      def deserialize(value)
        apply_transformers(value, @deserialize)
      end

      private

      def normalize_writable(value)
        case value
        when true then { on: %i[create update] }
        when false then { on: [] }
        when Hash then { on: Array(value[:on] || %i[create update]) }
        else { on: [] }
        end
      end

      def apply_defaults(options)
        defaults = {
          filterable: false,
          sortable: false,
          writable: false,
          serialize: nil,
          deserialize: nil,
          null_to_empty: false,
          nullable: false,  # Default to false (stricter by default)
          required: false,
          type: nil,
          enum: nil
        }

        defaults.merge(options)
      end

      def validate_attribute_exists!
        return if @klass.abstract_class

        # Check model first (DB column or model method) if model exists
        if @model_class
          return if @is_db_column || @model_class.instance_methods.include?(@name.to_sym)
        end

        # Check resource methods
        return if @klass.instance_methods.include?(@name.to_sym)

        # Attribute not found
        detail = if @model_class
                   "Undefined resource attribute '#{@name}' in #{@klass.send(:name_of_self)}: " \
                   'no DB column, no reader method on model, and no reader method on resource'
                 else
                   "Undefined resource attribute '#{@name}' in #{@klass.send(:name_of_self)}: " \
                   'no reader method on resource'
                 end
        error = ConfigurationError.new(
          code: :invalid_attribute,
          detail: detail,
          path: [@name]
        )

        Errors::Handler.handle(error, context: { attribute: @name, resource: @klass.send(:name_of_self) })
      end

      def validate_null_to_empty!
        return unless @null_to_empty
        return if %i[string text].include?(@type)

        detail = 'null_to_empty option can only be used on string/text attributes, ' \
                 "not #{@type} for '#{@name}' in #{@klass.send(:name_of_self)}"
        error = ConfigurationError.new(
          code: :invalid_null_to_empty,
          detail: detail,
          path: [@name]
        )

        Errors::Handler.handle(error, context: { attribute: @name, type: @type, resource: @klass.send(:name_of_self) })
      end

      def apply_null_to_empty_transformers!
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
              val.blank? ? nil : val
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

        column = @model_class.columns_hash[name.to_s]

        # Column with default not required (DB handles it)
        # Exception: Enum fields with defaults still required
        return false if column&.default.present? && !@model_class.defined_enums.key?(name.to_s)

        # null: false constraint means required
        !column&.null
      end

      def detect_nullable(name)
        return false unless @model_class
        return false unless @is_db_column

        column = @model_class.columns_hash[name.to_s]

        # Return true if column allows NULL, false if NOT NULL
        column&.null || false
      end
    end
  end
end
