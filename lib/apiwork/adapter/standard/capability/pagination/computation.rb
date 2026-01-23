# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              paginated, pagination_result = paginate
              result(
                data: paginated,
                document: { pagination: pagination_result[:pagination] },
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
