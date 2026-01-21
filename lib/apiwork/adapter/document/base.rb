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

        def contract(registrar, schema_class, actions, capabilities: [])
          self.class.response_types_class&.build(registrar, schema_class, actions, capabilities:)
        end

        def build_record_response(data, additions, state)
          raise NotImplementedError
        end

        def build_collection_response(data, additions, state)
          raise NotImplementedError
        end

        def build_error_response(data, state)
          raise NotImplementedError
        end
      end
    end
  end
end
