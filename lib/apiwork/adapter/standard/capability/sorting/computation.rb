# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              sort_params = request.query[:sort]
              return result(data:) if sort_params.blank?

              includes = IncludesResolver.new(schema_class).from_params(sort_params).keys
              sorted = Sort.apply(data, sort_params, schema_class)

              result(includes:, data: sorted)
            end
          end
        end
      end
    end
  end
end
