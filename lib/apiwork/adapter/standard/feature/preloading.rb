# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Preloading < Adapter::Feature
          feature_name :preloading
          applies_to :index, :show
          input :any

          def extract(request, schema_class)
            {}
          end

          def includes(params, schema_class)
            []
          end

          def apply(data, params, context)
            data
          end
        end
      end
    end
  end
end
