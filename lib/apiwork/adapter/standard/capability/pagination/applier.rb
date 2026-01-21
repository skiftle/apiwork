# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Applier < Adapter::Capability::Applier::Base
            def extract
              context.request.query[:page] || {}
            end

            def apply
              paginated, pagination_result = paginate
              context.metadata[:pagination] = pagination_result[:pagination]
              paginated
            end

            private

            def paginate
              case config.strategy
              when :offset
                OffsetPaginator.paginate(context.data, config, context.params)
              else
                CursorPaginator.paginate(context.data, config, context.params)
              end
            end
          end
        end
      end
    end
  end
end
