# frozen_string_literal: true

module Apiwork
  module Abstractable
    extend ActiveSupport::Concern

    included do
      class_attribute :_abstract_class, default: false
    end

    class_methods do
      def abstract_class=(value)
        self._abstract_class = value
      end

      def abstract_class
        _abstract_class
      end

      def abstract_class?
        _abstract_class
      end

      def inherited(subclass)
        super
        # Reset abstract flag so subclass doesn't inherit it
        subclass._abstract_class = false
      end
    end
  end
end
