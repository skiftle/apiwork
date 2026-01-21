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
              paginated, pagination_result = paginate(context.data, context.schema_class, context.params)
              context.metadata[:pagination] = pagination_result[:pagination]
              paginated
            end

            private

            def paginate(collection, schema_class, page_params)
              strategy = schema_class.adapter_config.pagination.strategy

              case strategy
              when :offset
                OffsetPaginator.paginate(collection, schema_class, page_params)
              else
                CursorPaginator.paginate(collection, schema_class, page_params)
              end
            end
          end
        end
      end
    end
  end
end
