# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Operation < Adapter::Capability::Operation::Base
            target :collection

            def apply
              params = request.query[:sort]
              return if params.blank?

              result(**Sort.apply(data, representation_class, params))
            end
          end
        end
      end
    end
  end
end
