# frozen_string_literal: true

module Apiwork
  module Adapter
    class CapabilityContext
      attr_reader :action,
                  :context,
                  :document_type,
                  :meta,
                  :representation_class,
                  :request

      def initialize(action:, context: {}, document_type: nil, meta: {}, representation_class: nil, request: nil)
        @action = action
        @context = context
        @document_type = document_type
        @meta = meta
        @representation_class = representation_class
        @request = request
      end

      def with_document_type(type)
        return self if document_type == type

        self.class.new(
          action:,
          context:,
          meta:,
          representation_class:,
          request:,
          document_type: type,
        )
      end
    end
  end
end
