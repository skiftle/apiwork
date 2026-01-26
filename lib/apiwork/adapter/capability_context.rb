# frozen_string_literal: true

module Apiwork
  module Adapter
    class CapabilityContext
      attr_reader :action,
                  :document_type,
                  :representation_class,
                  :request,
                  :user_context

      def initialize(action:, document_type:, representation_class:, request:, user_context:)
        @action = action
        @document_type = document_type
        @request = request
        @representation_class = representation_class
        @user_context = user_context
      end
    end
  end
end
