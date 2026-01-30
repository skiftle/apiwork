# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              params = request.query[:sort]
              return if params.blank?

              sorted_data, includes = Sort.apply(data, representation_class, params)

              result(includes:, data: sorted_data)
            end
          end
        end
      end
    end
  end
end
