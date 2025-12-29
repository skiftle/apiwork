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

      def initialize(name,
                     type,
                     schema_class,
                     allow_destroy: false,
                     class_name: nil,
                     deprecated: false,
                     description: nil,
                     example: nil,
                     filterable: false,
                     include: :optional,
                     nullable: nil,
                     optional: nil,
                     polymorphic: nil,
                     schema: nil,
                     sortable: false,
                     writable: false)
        @name = name
        @type = type
        @owner_schema_class = schema_class
        @model_class = schema_class.model_class
        @schema_class = schema || class_name
        validate_schema!
        @polymorphic = normalize_polymorphic(polymorphic)

        @filterable = filterable
        @sortable = sortable
        @include = include
        @writable = normalize_writable(writable)
        @allow_destroy = allow_destroy
        @nullable = nullable.nil? ? optional : nullable
        @description = description
        @example = example
        @deprecated = deprecated

        detect_polymorphic_discriminator! if @polymorphic

        validate_include_option!
        validate_association_exists!
        validate_polymorphic!
        validate_nested_attributes!
        validate_query_options!
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

      def schema_class_name
        @schema_class_name ||= @owner_schema_class
                               .name
                               .demodulize
                               .delete_suffix('Schema')
                               .underscore
      end

      def resolve_polymorphic_schema(tag)
        return nil unless @polymorphic

        explicit = @polymorphic[tag.to_sym]
        return explicit if explicit

        infer_polymorphic_schema(tag)
      end

      private

      def normalize_polymorphic(value)
        return nil unless value

        case value
        when Array
          value.each_with_object({}) { |tag, hash| hash[tag.to_sym] = nil }
        when Hash
          validate_polymorphic_hash!(value)
          value.transform_keys(&:to_sym)
        else
          raise ConfigurationError, "polymorphic must be an Array or Hash, got #{value.class}"
        end
      end

      def validate_polymorphic_hash!(hash)
        hash.each do |tag, schema|
          next unless schema.is_a?(String)

          raise ConfigurationError,
                'polymorphic values must be class references, not strings. ' \
                "Use `#{tag}: #{schema.split('::').last}` instead of `#{tag}: '#{schema}'`"
        end
      end

      def validate_schema!
        return unless @schema_class
        return unless @schema_class.is_a?(String)

        raise ConfigurationError,
              'schema must be a class reference, not a string. ' \
              "Use `schema: #{@schema_class.split('::').last}` instead of `schema: '#{@schema_class}'`"
      end

      def infer_polymorphic_schema(tag)
        namespace = @owner_schema_class.name.deconstantize
        schema_name = "#{tag.to_s.camelize}Schema"

        full_name = namespace.present? ? "#{namespace}::#{schema_name}" : schema_name
        full_name.safe_constantize
      end

      def column_for(name)
        @model_class.columns_hash[name.to_s]
      end

      def normalize_writable(value)
        case value
        when true  then { on: %i[create update] }
        when false then { on: [] }
        when Hash  then { on: Array(value[:on] || %i[create update]) }
        else            { on: [] }
        end
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

        raise_polymorphic_error(:filterable) if @filterable
        raise_polymorphic_error(:sortable) if @sortable
        raise_polymorphic_error(:writable, suffix: '. Rails does not support accepts_nested_attributes_for on polymorphic associations') if writable?
      end

      def raise_polymorphic_error(option, suffix: '')
        raise ConfigurationError.new(
          code: :invalid_polymorphic_option,
          detail: "Polymorphic association '#{@name}' cannot use #{option}: true#{suffix}",
          path: [@name],
        )
      end

      def validate_include_option!
        valid_options = %i[always optional]
        return if valid_options.include?(@include)

        detail = "Invalid include option ':#{@include}' for association '#{@name}'. " \
                 'Must be :always or :optional'
        error = ConfigurationError.new(
          code: :invalid_include_option,
          detail: detail,
          path: [@name],
        )

        raise error
      end

      def validate_association_exists!
        return if @owner_schema_class.abstract?
        return if @model_class.nil?
        return if @schema_class

        reflection = @model_class.reflect_on_association(@name)
        return if reflection

        detail = "Undefined association '#{@name}' in #{@owner_schema_class.name}: no association on model"
        error = ConfigurationError.new(
          code: :invalid_association,
          detail: detail,
          path: [@name],
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
            path: [@name],
          )

          raise error
        end

        nested_options = @model_class.nested_attributes_options[@name]
        @allow_destroy = nested_options[:allow_destroy] || false if nested_options
      end

      def validate_query_options!
        return unless @filterable || @sortable
        return if @owner_schema_class.abstract?
        return unless @model_class

        reflection = @model_class.reflect_on_association(@name)
        return if reflection

        raise ConfigurationError.new(
          code: :query_option_requires_association,
          detail: "Association #{@name}: filterable/sortable requires an ActiveRecord association for JOINs",
          path: [@name],
        )
      end
    end
  end
end
