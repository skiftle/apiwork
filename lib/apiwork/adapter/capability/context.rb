# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Context
        attr_reader :action,
                    :context,
                    :meta,
                    :representation_class,
                    :request

        def initialize(action:, context: {}, meta: {}, representation_class: nil, request: nil)
          @action = action
          @context = context
          @meta = meta
          @representation_class = representation_class
          @request = request
        end
      end
    end
  end
end
