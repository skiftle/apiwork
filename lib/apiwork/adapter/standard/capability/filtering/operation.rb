# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Operation < Adapter::Capability::Operation::Base
            target :collection

            def apply
              params = request.query[:filter]
              return if params.blank?

              result(**Filter.apply(data, representation_class, params))
            end
          end
        end
      end
    end
  end
end
