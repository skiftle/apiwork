# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ResponseTypes < Adapter::Capability::ResponseTypes::Base
            def collection(context)
              pagination_config = context.schema_class.adapter_config.pagination
              pagination_type = pagination_config.strategy == :offset ? :offset_pagination : :cursor_pagination
              context.response.reference :pagination, to: pagination_type
            end

            def record(context)
              # Pagination only applies to collections
            end
          end
        end
      end
    end
  end
end
