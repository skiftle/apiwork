# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Writing < Adapter::Feature
          feature_name :writing
          applies_to :create, :update

          request_transformer OpFieldTransformer, post: true

          def contract(registrar, schema_class, actions)
            TypeBuilder.build(registrar, schema_class)
          end
        end
      end
    end
  end
end
