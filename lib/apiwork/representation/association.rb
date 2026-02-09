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
      # The description for this association.
      #
      # @return [String, nil]
      attr_reader :description

      # @api public
      # The example for this association.
      #
      # @return [Object, nil]
      attr_reader :example

      # @api public
      # The include for this association.
      #
      # :always or :optional.
      #
      # @return [Symbol]
      attr_reader :include

      # @api public
      # The name for this association.
      #
      # @return [Symbol]
      attr_reader :name

      # @api public
      # The polymorphic for this association.
      #
      # @return [Array<Class<Representation::Base>>, nil]
      attr_reader :polymorphic

      # @api public
      # The type for this association.
      #
      # @return [Symbol]
      attr_reader :type

      # @api public
      # The model class for this association.
      #
      # @return [Class<ActiveRecord::Base>]
      attr_reader :model_class

      attr_reader :allow_destroy,
                  :discriminator

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
        @nullable = nullable
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
      # Whether this association is deprecated.
      #
      # @return [Boolean]
      def deprecated?
        @deprecated
      end

      # @api public
      # Whether this association is filterable.
      #
      # @return [Boolean]
      def filterable?
        @filterable
      end

      # @api public
      # Whether this association is sortable.
      #
      # @return [Boolean]
      def sortable?
        @sortable
      end

      # @api public
      # Whether this association is writable.
      #
      # @return [Boolean]
      # @see #writable_for?
      def writable?
        @writable[:on].any?
      end

      # @api public
      # Whether this association is writable for the given action.
      #
      # @param action [Symbol] :create or :update
      # @return [Boolean]
      # @see #writable?
      def writable_for?(action)
        @writable[:on].include?(action)
      end

      # @api public
      # Whether this association is a collection.
      #
      # @return [Boolean]
      def collection?
        @type == :has_many
      end

      # @api public
      # Whether this association is singular.
      #
      # @return [Boolean]
      def singular?
        %i[has_one belongs_to].include?(@type)
      end

      # @api public
      # Whether this association is polymorphic.
      #
      # @return [Boolean]
      def polymorphic?
        @polymorphic.present?
      end

      # @api public
      # Whether this association is nullable.
      #
      # @return [Boolean]
      def nullable?
        return @nullable unless @nullable.nil?

        case @type
        when :belongs_to
          return false unless @model_class

          foreign_key = detect_foreign_key
          column = column_for(foreign_key)
          return false unless column

          column.null
        when :has_one, :has_many
          false
        end
      end

      # @api public
      # Uses explicit `representation:` if set, otherwise inferred from the model.
      #
      # @return [Class<Representation::Base>, nil]
      def representation_class
        @representation_class || inferred_representation_class
      end

      def representation_class_name
        @representation_class_name ||= @owner_representation_class
          .name
          .demodulize
          .delete_suffix('Representation')
          .underscore
      end

      def find_representation_for_type(type_value)
        return nil unless @polymorphic

        @polymorphic.find do |representation_class|
          representation_class.model_class.polymorphic_name == type_value
        end
      end

      private

      def inferred_representation_class
        return nil if polymorphic?
        return nil unless @model_class

        reflection = @model_class.reflect_on_association(@name)
        return nil if reflection.nil? || reflection.polymorphic?

        namespace = @owner_representation_class.name.deconstantize
        "#{namespace}::#{reflection.klass.name.demodulize}Representation".safe_constantize
      end

      def normalize_polymorphic(value)
        return nil unless value
        return nil unless value.is_a?(Array)

        value.each do |item|
          validate_polymorphic_item!(item)
        end

        value
      end

      def validate_polymorphic_item!(item)
        return if item.is_a?(Class) && item < Apiwork::Representation::Base

        if item.is_a?(Symbol)
          raise ConfigurationError,
                'polymorphic requires representation classes, not symbols. ' \
                "Use `polymorphic: [#{item.to_s.camelize}Representation]` instead of `polymorphic: [:#{item}]`"
        elsif item.is_a?(String)
          raise ConfigurationError,
                'polymorphic requires representation classes, not strings. ' \
                "Use `polymorphic: [#{item.split('::').last}]` instead of `polymorphic: ['#{item}']`"
        else
          raise ConfigurationError,
                "polymorphic requires representation classes, got #{item.class}"
        end
      end

      def validate_representation!
        return unless @representation_class
        return unless @representation_class.is_a?(String)

        raise ConfigurationError,
              'representation must be a class reference, not a string. ' \
              "Use `representation: #{@representation_class.split('::').last}` instead of `representation: '#{@representation_class}'`"
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
