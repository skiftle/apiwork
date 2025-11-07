# frozen_string_literal: true

module Apiwork
  module Concerns
    # Provides abstract class functionality for Schema and Contract base classes
    #
    # When included, provides:
    # - abstract_class getter/setter
    # - abstract_class? predicate method
    # - Automatic reset of abstract flag on inheritance
    #
    # @example
    #   class BaseSchema < Apiwork::Schema::Base
    #     self.abstract_class = true
    #   end
    #
    #   class PostSchema < BaseSchema
    #     # abstract_class is automatically false here
    #   end
    #
    module AbstractClass
      extend ActiveSupport::Concern

      included do
        class_attribute :_abstract_class, default: false
      end

      class_methods do
        # Set whether this class is abstract
        #
        # @param value [Boolean] true if abstract, false otherwise
        def abstract_class=(value)
          self._abstract_class = value
        end

        # Get whether this class is abstract
        #
        # @return [Boolean] true if abstract, false otherwise
        def abstract_class
          _abstract_class
        end

        # Predicate method to check if class is abstract
        #
        # @return [Boolean] true if abstract, false otherwise
        def abstract_class?
          _abstract_class
        end

        # Hook to reset abstract flag on inheritance
        # Ensures subclasses don't automatically inherit abstract status
        #
        # @param subclass [Class] the inheriting class
        def inherited(subclass)
          super
          # Reset abstract flag so subclass doesn't inherit it
          subclass._abstract_class = false
        end
      end
    end
  end
end
