# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Represents an association defined on a representation.
    #
    # Associations map to model relationships and define serialization behavior.
    # Used by adapters to build contracts and serialize records.
    #
    # @example
    #   association = InvoiceRepresentation.associations[:customer]
    #   association.name         # => :customer
    #   association.type         # => :belongs_to
    #   association.representation_class # => CustomerRepresentation
    class Association
      # @api public
      # @return [Boolean] whether this association is deprecated
      attr_reader :deprecated

      # @api public
      # @return [String, nil] documentation description
      attr_reader :description

      # @api public
      # @return [Object, nil] example value for documentation
      attr_reader :example

      # @api public
      # @return [Symbol] include mode (:always or :optional)
      attr_reader :include

      # @api public
      # @return [Symbol] association name
      attr_reader :name

      # @api public
      # @return [Hash, nil] polymorphic type mappings
      attr_reader :polymorphic

      # @api public
      # @return [Representation::Base, nil] the associated representation class
      attr_reader :representation_class

      # @api public
      # @return [Symbol] association type (:has_one, :has_many, :belongs_to)
      attr_reader :type

      attr_reader :allow_destroy,
                  :discriminator,
                  :model_class

      def initialize(
        name,
        type,
        owner_representation_class,
        allow_destroy: false,
        deprecated: false,
        description: nil,
        example: nil,
        filterable: false,
        include: :optional,
        nullable: nil,
        optional: nil,
        polymorphic: nil,
        representation: nil,
        sortable: false,
        writable: false
      )
        @name = name
        @type = type
        @owner_representation_class = owner_representation_class
        @model_class = owner_representation_class.model_class
        @representation_class = representation
        validate_representation!
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

      # @api public
      # @return [Boolean] whether filtering is enabled
      def filterable?
        @filterable
      end

      # @api public
      # @return [Boolean] whether sorting is enabled
      def sortable?
        @sortable
      end

      # @api public
      # @return [Boolean] whether this association is writable
      def writable?
        @writable[:on].any?
      end

      # @api public
      # @param action [Symbol] the action to check (:create or :update)
      # @return [Boolean] whether this association is writable for the given action
      def writable_for?(action)
        @writable[:on].include?(action)
      end

      # @api public
      # @return [Boolean] whether this is a has_many association
      def collection?
        @type == :has_many
      end

      # @api public
      # @return [Boolean] whether this is a has_one or belongs_to association
      def singular?
        %i[has_one belongs_to].include?(@type)
      end

      # @api public
      # @return [Boolean] whether this is a polymorphic association
      def polymorphic?
        @polymorphic.present?
      end

      # @api public
      # @return [Boolean] whether this association can be null
      def nullable?
        return @nullable unless @nullable.nil?
        return false unless @type == :belongs_to
        return false unless @model_class

        foreign_key = detect_foreign_key
        column = column_for(foreign_key)
        return false unless column

        column.null
      end

      def representation_class_name
        @representation_class_name ||= @owner_representation_class
          .name
          .demodulize
          .delete_suffix('Representation')
          .underscore
      end

      def resolve_polymorphic_representation(tag)
        return nil unless @polymorphic

        explicit = @polymorphic[tag.to_sym]
        return explicit if explicit

        infer_polymorphic_representation(tag)
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
        hash.each do |tag, representation|
          next unless representation.is_a?(String)

          raise ConfigurationError,
                'polymorphic values must be class references, not strings. ' \
                "Use `#{tag}: #{representation.split('::').last}` instead of `#{tag}: '#{representation}'`"
        end
      end

      def validate_representation!
        return unless @representation_class
        return unless @representation_class.is_a?(String)

        raise ConfigurationError,
              'representation must be a class reference, not a string. ' \
              "Use `representation: #{@representation_class.split('::').last}` instead of `representation: '#{@representation_class}'`"
      end

      def infer_polymorphic_representation(tag)
        namespace = @owner_representation_class.name.deconstantize
        representation_name = "#{tag.to_s.camelize}Representation"

        (namespace.present? ? "#{namespace}::#{representation_name}" : representation_name).safe_constantize
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
        return "#{@name}_id" unless reflection

        reflection.foreign_key
      end

      def detect_polymorphic_discriminator!
        return unless @model_class

        reflection = @model_class.reflect_on_association(@name)
        return unless reflection
        return unless reflection.foreign_type

        @discriminator = reflection.foreign_type.to_sym
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
          detail:,
          code: :invalid_include_option,
          path: [@name],
        )

        raise error
      end

      def validate_association_exists!
        return if @owner_representation_class.abstract?
        return if @model_class.nil?
        return if @representation_class

        reflection = @model_class.reflect_on_association(@name)
        return if reflection

        detail = "Undefined association '#{@name}' in #{@owner_representation_class.name}: no association on model"
        error = ConfigurationError.new(
          detail:,
          code: :invalid_association,
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
            detail:,
            code: :missing_nested_attributes,
            path: [@name],
          )

          raise error
        end

        nested_options = @model_class.nested_attributes_options[@name]
        return unless nested_options

        @allow_destroy = nested_options[:allow_destroy]
      end

      def validate_query_options!
        return unless @filterable || @sortable
        return if @owner_representation_class.abstract?
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
