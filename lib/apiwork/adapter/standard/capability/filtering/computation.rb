# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              params = request.query[:filter]
              return if params.blank?

              filtered_data, includes = Filter.apply(data, representation_class, params)

              result(includes:, data: filtered_data)
            end
          end
        end
      end
    end
  end
end
