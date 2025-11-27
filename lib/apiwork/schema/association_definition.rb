# frozen_string_literal: true

module Apiwork
  module Schema
    class AssociationDefinition
      attr_reader :name,
                  :type,
                  :schema_class,
                  :allow_destroy,
                  :model_class,
                  :description,
                  :example,
                  :deprecated,
                  :polymorphic,
                  :discriminator

      def initialize(name, type:, schema_class:, **options)
        @name = name
        @type = type
        @klass = schema_class
        @model_class = schema_class.model_class
        @schema_class = options[:schema]
        @polymorphic = options[:polymorphic] if options[:polymorphic].is_a?(Hash)

        options = apply_defaults(options)

        @filterable = options[:filterable]
        @sortable = options[:sortable]
        @include = options[:include]
        writable_value = options[:writable]
        @writable = case writable_value
                    when true then { on: %i[create update] }
                    when false then { on: [] }
                    when Hash then { on: Array(writable_value[:on] || %i[create update]) }
                    else { on: [] }
                    end
        @allow_destroy = options[:allow_destroy]
        @nullable = options[:nullable]

        @description = options[:description]
        @example = options[:example]
        @deprecated = options[:deprecated]

        detect_polymorphic_discriminator! if @polymorphic

        validate_include_option!
        validate_association_exists!
        validate_polymorphic!
        validate_nested_attributes!
      end

      def filterable?
        @filterable
      end

      def sortable?
        @sortable
      end

      def always_included?
        @include == :always
      end

      def optional_included?
        @include == :optional
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

      def collection?
        @type == :has_many
      end

      def singular?
        %i[has_one belongs_to].include?(@type)
      end

      def polymorphic?
        @polymorphic.present?
      end

      def nullable?
        return @nullable unless @nullable.nil?

        if @type == :belongs_to && @model_class
          foreign_key = detect_foreign_key
          column = column_for(foreign_key)
          return column.null if column
        end

        false
      end

      private

      def column_for(name)
        @model_class.columns_hash[name.to_s]
      end

      def apply_defaults(options)
        {
          filterable: false,
          sortable: false,
          include: :optional,
          writable: false,
          allow_destroy: false,
          nullable: nil, # nil = auto-detect from DB, true/false = explicit override
          description: nil,
          example: nil,
          deprecated: false
        }.merge(options)
      end

      def detect_foreign_key
        reflection = @model_class.reflect_on_association(@name)
        reflection&.foreign_key || "#{@name}_id"
      end

      def detect_polymorphic_discriminator!
        return unless @model_class

        reflection = @model_class.reflect_on_association(@name)
        return unless reflection

        @discriminator = reflection.foreign_type&.to_sym
      end

      def validate_polymorphic!
        return unless polymorphic?

        if @filterable
          detail = "Polymorphic association '#{@name}' cannot use filterable: true"
          error = ConfigurationError.new(
            code: :invalid_polymorphic_option,
            detail: detail,
            path: [@name]
          )
          raise error
        end

        if @sortable
          detail = "Polymorphic association '#{@name}' cannot use sortable: true"
          error = ConfigurationError.new(
            code: :invalid_polymorphic_option,
            detail: detail,
            path: [@name]
          )
          raise error
        end

        return unless @writable[:on].any?

        detail = "Polymorphic association '#{@name}' cannot use writable: true. " \
                 'Rails does not support accepts_nested_attributes_for on polymorphic associations'
        error = ConfigurationError.new(
          code: :invalid_polymorphic_option,
          detail: detail,
          path: [@name]
        )
        raise error
      end

      def validate_include_option!
        valid_options = %i[always optional]
        return if valid_options.include?(@include)

        detail = "Invalid include option ':#{@include}' for association '#{@name}'. " \
                 'Must be :always or :optional'
        error = ConfigurationError.new(
          code: :invalid_include_option,
          detail: detail,
          path: [@name]
        )

        raise error
      end

      def validate_association_exists!
        return if @klass.abstract_class || @model_class.nil? || @schema_class

        reflection = @model_class.reflect_on_association(@name)
        return if reflection

        detail = "Undefined resource association '#{@name}' in #{@klass.name}: no association on model"
        error = ConfigurationError.new(
          code: :invalid_association,
          detail: detail,
          path: [@name]
        )

        raise error
      end

      def validate_nested_attributes!
        return unless @model_class
        return unless writable?

        nested_attribute_method = "#{@name}_attributes="
        unless @model_class.instance_methods.include?(nested_attribute_method.to_sym)
          detail = "#{@model_class.name} doesn't accept nested attributes for #{@name}. " \
                   "Add: accepts_nested_attributes_for :#{@name}"
          error = ConfigurationError.new(
            code: :missing_nested_attributes,
            detail: detail,
            path: [@name]
          )

          raise error
        end

        nested_options = @model_class.nested_attributes_options[@name]
        @allow_destroy = nested_options[:allow_destroy] || false if nested_options
      end
    end
  end
end
