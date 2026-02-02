# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation < Adapter::Capability::Operation::Base
            target :collection

            metadata_shape do
              reference(:pagination, to: (options.strategy == :cursor ? :cursor_pagination : :offset_pagination))
            end

            def apply
              params = request.query.fetch(:page, {})
              result(**Paginate.apply(data, options, params))
            end
          end
        end
      end
    end
  end
end
