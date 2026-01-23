# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            envelope do
              shape do
                pagination_type = options.strategy == :offset ? :offset_pagination : :cursor_pagination
                reference :pagination, to: pagination_type
              end

              build do
                json[:pagination] = additions[:pagination]
              end
            end

            def apply
              paginated, pagination_result = paginate
              result(
                data: paginated,
                pagination: pagination_result[:pagination],
              )
            end

            private

            def paginate
              page_params = request.query[:page] || {}

              case options.strategy
              when :offset
                OffsetPaginator.paginate(data, options, page_params)
              else
                CursorPaginator.paginate(data, options, page_params)
              end
            end
          end
        end
      end
    end
  end
end
