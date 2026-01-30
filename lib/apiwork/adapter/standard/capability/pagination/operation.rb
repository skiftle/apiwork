# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation < Adapter::Capability::Operation::Base
            scope :collection

            metadata do |shape|
              shape.reference(:pagination, to: (shape.options.strategy == :cursor ? :cursor_pagination : :offset_pagination))
            end

            def apply
              data, metadata = paginate
              result(data:, metadata:)
            end

            private

            def paginate
              params = request.query.fetch(:page, {})
              Paginate.apply(data, options, params)
            end
          end
        end
      end
    end
  end
end
