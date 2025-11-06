# frozen_string_literal: true

module Apiwork
  module Schema
    class AttributeDefinition
      attr_reader :name, :type, :enum, :required

      def initialize(name, klass:, **options)
        @name = name
        @klass = klass

        # Normalize and apply defaults
        options = apply_defaults(options)

        # Store all options
        @filterable = options[:filterable]
        @sortable = options[:sortable]
        @writable = normalize_writable(options[:writable])
        @serialize = options[:serialize]
        @deserialize = options[:deserialize]
        @null_to_empty = options[:null_to_empty]
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
          required: false,
          type: nil,
          enum: nil
        }

        defaults.merge(options)
      end

      def validate_attribute_exists!
        return if @klass.abstract_class

        # Check if resource has a reader method for this attribute
        resource_has_method = @klass.instance_methods.include?(@name.to_sym)
        return if resource_has_method

        detail = "Undefined resource attribute '#{@name}' in #{@klass.send(:name_of_self)}: " \
                 'no reader method on resource'
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
    end
  end
end
