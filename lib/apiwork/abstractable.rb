# frozen_string_literal: true

module Apiwork
  module Abstractable
    extend ActiveSupport::Concern

    included do
      class_attribute :_abstract, default: false, instance_predicate: false
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
