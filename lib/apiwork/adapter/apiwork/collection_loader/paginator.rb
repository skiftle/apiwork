# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class Paginator
          def self.perform(relation, schema_class, page_params)
            strategy = schema_class.resolve_option(:pagination, :strategy)

            case strategy
            when :cursor
              CursorPaginator.perform(relation, schema_class, page_params)
            else
              PagePaginator.perform(relation, schema_class, page_params)
            end
          end
        end
      end
    end
  end
end
