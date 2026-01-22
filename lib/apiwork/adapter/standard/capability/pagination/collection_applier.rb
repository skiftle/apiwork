# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class CollectionApplier < Adapter::Capability::CollectionApplier::Base
            def apply
              paginated, pagination_result = paginate
              result(
                collection: paginated,
                pagination: pagination_result[:pagination],
              )
            end

            private

            def paginate
              page_params = request.query[:page] || {}

              case options.strategy
              when :offset
                OffsetPaginator.paginate(collection, options, page_params)
              else
                CursorPaginator.paginate(collection, options, page_params)
              end
            end
          end
        end
      end
    end
  end
end
