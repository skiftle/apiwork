# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation < Adapter::Capability::Operation::Base
            target :collection

            metadata do |shape|
              shape.reference(:pagination, to: (shape.options.strategy == :cursor ? :cursor_pagination : :offset_pagination))
            end

            def apply
              params = request.query.fetch(:page, {})
              data, metadata = Paginate.apply(self.data, options, params)
              result(data:, metadata:)
            end
          end
        end
      end
    end
  end
end
