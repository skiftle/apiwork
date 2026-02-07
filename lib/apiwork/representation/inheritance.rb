# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Tracks STI subclass representations for a base representation.
    #
    # Created automatically when a representation's model uses STI.
    # Provides resolution of records to their correct subclass representation.
    #
    # @example
    #   ClientRepresentation.inheritance.column      # => :type
    #   ClientRepresentation.inheritance.subclasses  # => [PersonClientRepresentation, ...]
    #   ClientRepresentation.inheritance.resolve(record)  # => PersonClientRepresentation
    class Inheritance
      # @api public
      # The base representation class for this inheritance.
      #
      # @return [Class<Representation::Base>]
      attr_reader :base_class

      # @api public
      # All registered subclass representations.
      #
      # @return [Array<Class<Representation::Base>>]
      attr_reader :subclasses

      def initialize(base_class)
        @base_class = base_class
        @subclasses = []
      end

      # @api public
      # The STI column name from the model.
      #
      # @return [Symbol]
      def column
        @base_class.model_class.inheritance_column.to_sym
      end

      # @api public
      # Resolves a record to its subclass representation.
      #
      # @param record [ActiveRecord::Base] the record to resolve
      # @return [Class<Representation::Base>, nil]
      def resolve(record)
        type_value = record.public_send(column)
        @subclasses.find { |klass| klass.model_class.sti_name == type_value }
      end

      # @api public
      # Whether this inheritance needs transformation.
      #
      # @return [Boolean]
      def needs_transform?
        @subclasses.any? { |klass| klass.sti_name != klass.model_class.sti_name }
      end

      # @api public
      # Mapping of API names to database type values.
      #
      # @return [Hash{String => String}]
      def mapping
        @subclasses.to_h { |klass| [klass.sti_name, klass.model_class.sti_name] }
      end

      def register(representation_class)
        @subclasses << representation_class
      end

      def subclass?(representation_class)
        @subclasses.include?(representation_class)
      end
    end
  end
end
