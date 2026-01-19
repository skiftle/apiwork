# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Serialization < Adapter::Feature
          feature_name :serialization

          def contract(registrar, schema_class, actions)
            TypeBuilder.build(registrar, schema_class)
          end
        end
      end
    end
  end
end
