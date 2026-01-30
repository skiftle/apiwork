# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Computation < Adapter::Capability::Computation::Base
            scope :collection

            def apply
              data, metadata = paginate
              result(data:, metadata:)
            end

            private

            def paginate
              params = request.query.fetch(:page, {})

              case options.strategy
              when :offset
                OffsetPaginator.paginate(data, options, params)
              else
                CursorPaginator.paginate(data, options, params)
              end
            end
          end
        end
      end
    end
  end
end
