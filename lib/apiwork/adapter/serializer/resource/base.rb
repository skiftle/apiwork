# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Resource
        class Base
          class << self
            def types(klass)
              @types_class = klass
            end

            attr_reader :types_class
          end

          attr_reader :representation_class

          def initialize(representation_class)
            @representation_class = representation_class
          end

          def register_types(contract_class)
            self.class.types_class&.build(contract_class, representation_class)
          end

          def serialize(resource, context:, serialize_options:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
