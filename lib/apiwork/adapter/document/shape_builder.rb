# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class ShapeBuilder < SimpleDelegator
        attr_reader :context

        def initialize(object, context)
          super(object)
          @context = context
        end
      end
    end
  end
end
