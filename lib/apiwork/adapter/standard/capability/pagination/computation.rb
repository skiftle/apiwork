# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              data, pagination = paginate
              result(data:, document: { pagination: })
            end

            private

            def paginate
              page_params = request.query.fetch(:page, {})

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
