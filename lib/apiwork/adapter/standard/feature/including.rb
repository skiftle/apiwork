# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Including < Adapter::Feature
          feature_name :including

          def contract(registrar, schema_class)
            TypeBuilder.build(registrar, schema_class)
          end

          def apply(data, state)
            data
          end
        end
      end
    end
  end
end
