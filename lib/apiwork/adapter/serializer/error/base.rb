# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        class Base
          class << self
            def types(klass)
              @types_class = klass
            end

            attr_reader :types_class
          end

          def register_types(api_class, features)
            self.class.types_class&.build(api_class, features)
          end

          def serialize(error, context:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
