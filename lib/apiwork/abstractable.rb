# frozen_string_literal: true

module Apiwork
  # @api private
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
