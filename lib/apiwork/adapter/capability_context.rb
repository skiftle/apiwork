# frozen_string_literal: true

module Apiwork
  module Adapter
    class CapabilityContext
      attr_reader :action,
                  :schema_class,
                  :user_context

      def initialize(action:, schema_class:, user_context:)
        @action = action
        @schema_class = schema_class
        @user_context = user_context
      end
    end
  end
end
