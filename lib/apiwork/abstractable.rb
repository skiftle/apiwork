# frozen_string_literal: true

module Apiwork
  # @api public
  # Concern that adds abstract class functionality.
  #
  # Include this in base classes to mark them as abstract.
  # Abstract classes don't require a model and serve as base classes.
  #
  # @!scope class
  # @!method abstract!
  #   @api public
  #   Marks this class as abstract.
  #
  #   Abstract classes don't require a model and serve as base classes.
  #   Subclasses automatically become non-abstract.
  #   @return [void]
  #   @example
  #     class ApplicationSchema < Apiwork::Schema::Base
  #       abstract!
  #     end
  #
  # @!method abstract?
  #   @api public
  #   Returns whether this class is abstract.
  #   @return [Boolean] true if abstract
  module Abstractable
    extend ActiveSupport::Concern

    included do
      class_attribute :_abstract, instance_predicate: false, default: false
    end

    class_methods do
      def abstract!
        self._abstract = true
      end

      def abstract?
        _abstract
      end

      def inherited(subclass)
        super
        subclass._abstract = false
      end
    end
  end
end
