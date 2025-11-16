# frozen_string_literal: true

module Apiwork
  module Abstractable
    extend ActiveSupport::Concern

    included do
      class_attribute :abstract_class, instance_predicate: false, default: false
    end

    class_methods do
      def abstract
        self.abstract_class = true
      end

      def abstract?
        abstract_class
      end

      def inherited(subclass)
        super
        subclass.abstract_class = false
      end
    end
  end
end
