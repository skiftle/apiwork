# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionLoader
        class Paginator
          def self.paginate(relation, schema_class, pagination_params)
            strategy = schema_class.resolve_option(:pagination, :strategy)

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
