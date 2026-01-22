# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Shape < Adapter::Capability::Shape::Base
            def build(object, context)
              pagination_config = context.schema_class.adapter_config.pagination
              pagination_type = pagination_config.strategy == :offset ? :offset_pagination : :cursor_pagination
              object.reference :pagination, to: pagination_type
            end
          end
        end
      end
    end
  end
end
