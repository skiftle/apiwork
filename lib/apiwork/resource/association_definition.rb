# frozen_string_literal: true

module Apiwork
  module Resource
    class AssociationDefinition
      attr_reader :name, :type, :resource_class, :allow_destroy

      def initialize(name, type:, klass:, **options)
        @name = name
        @type = type # :has_one, :has_many, :belongs_to
        @klass = klass
        @model_class = klass.model_class
        @resource_class = options[:resource]
        @filterable = options.fetch(:filterable, false)
        @sortable = options.fetch(:sortable, false)
        @writable = normalize_writable(options.fetch(:writable, false))
        @allow_destroy = options[:allow_destroy]

        # Validate
        validate_association_exists!
        validate_nested_attributes! if @writable[:on].any?
      end

      # Query methods
      def filterable?(context = nil)
        return @filterable.call(context) if @filterable.is_a?(Proc)

        @filterable
      end

      def sortable?(context = nil)
        return @sortable.call(context) if @sortable.is_a?(Proc)

        @sortable
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

      # Type checks
      def collection?
        @type == :has_many
      end

      def singular?
        %i[has_one belongs_to].include?(@type)
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

      def validate_association_exists!
        return if @klass.abstract_class || !@model_class || @resource_class

        reflection = @model_class.reflect_on_association(@name)
        return if reflection

        detail = "Undefined resource association '#{@name}' in #{@klass.send(:name_of_self)}: no association on model"
        error = ConfigurationError.new(
          code: :invalid_association,
          detail: detail,
          path: [@name]
        )

        Errors::Handler.handle(error, context: { association: @name, resource: @klass.send(:name_of_self) })
      end

      def validate_nested_attributes!
        return unless @model_class

        nested_attribute_method = "#{@name}_attributes="
        unless @model_class.instance_methods.include?(nested_attribute_method.to_sym)
          detail = "#{@model_class.name} doesn't accept nested attributes for #{@name}. " \
                   "Add: accepts_nested_attributes_for :#{@name}"
          error = ConfigurationError.new(
            code: :missing_nested_attributes,
            detail: detail,
            path: [@name]
          )

          Errors::Handler.handle(error, context: { association: @name, model: @model_class.name })
        end

        nested_options = @model_class.nested_attributes_options[@name]
        @allow_destroy = nested_options[:allow_destroy] || false if nested_options
      end
    end
  end
end
