# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              filter_params = request.query[:filter]
              return if filter_params.blank?

              includes = IncludesResolver.new(representation_class).from_params(filter_params).keys
              filtered = Filter.apply(data, filter_params, representation_class)

              result(includes:, data: filtered)
            end
          end
        end
      end
    end
  end
end
