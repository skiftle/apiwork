# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Base
        class << self
          def response_types(klass)
            @response_types_class = klass
          end

          attr_reader :response_types_class
        end

        attr_reader :schema_class

        def initialize(schema_class = nil)
          @schema_class = schema_class
        end

        def contract(registrar, actions, capabilities: [])
          self.class.response_types_class&.build(registrar, schema_class, actions, capabilities:)
        end

        def build_response(*)
          raise NotImplementedError
        end
      end
    end
  end
end
