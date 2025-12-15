# frozen_string_literal: true

module Apiwork
  module Registrable
    extend ActiveSupport::Concern

    included do
      class_attribute :_identifier, instance_predicate: false
    end

    class_methods do
      def identifier(name = nil)
        self._identifier = name.to_sym if name
        _identifier
      end
    end
  end
end
