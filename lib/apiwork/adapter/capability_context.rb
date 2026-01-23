# frozen_string_literal: true

module Apiwork
  module Adapter
    class CapabilityContext
      attr_reader :action,
                  :document_type,
                  :request,
                  :schema_class,
                  :user_context

      def initialize(action:, document_type:, request:, schema_class:, user_context:)
        @action = action
        @document_type = document_type
        @request = request
        @schema_class = schema_class
        @user_context = user_context
      end
    end
  end
end
