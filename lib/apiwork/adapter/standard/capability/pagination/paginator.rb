# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination < Adapter::Capability::Base
          class Paginator
            def self.paginate(relation, schema_class, pagination_params)
              strategy = schema_class.adapter_config.pagination.strategy

              case strategy
              when :offset
                OffsetPaginator.paginate(relation, schema_class, pagination_params)
              else
                CursorPaginator.paginate(relation, schema_class, pagination_params)
              end
            end
          end
        end
      end
    end
  end
end
