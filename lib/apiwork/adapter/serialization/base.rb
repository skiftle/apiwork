# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serialization
      class Base
        class << self
          def types(klass)
            @types_class = klass
          end

          def resource_types(klass)
            @resource_types_class = klass
          end

          attr_reader :resource_types_class, :types_class
        end

        def api(api_class, features)
          self.class.types_class&.build(api_class, features)
        end

        def contract(contract_class, representation_class, actions)
          self.class.resource_types_class&.build(contract_class, representation_class)
        end

        def serialize_resource(resource, context:, serialize_options:)
          raise NotImplementedError
        end

        def serialize_error(error, context:)
          raise NotImplementedError
        end
      end
    end
  end
end
