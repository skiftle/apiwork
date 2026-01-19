# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Pagination < Adapter::Feature
          feature_name :pagination

          option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
          option :default_size, default: 20, type: :integer
          option :max_size, default: 100, type: :integer

          def apply(data, state)
            return data unless state.action.index?
            return data unless state.schema_class
            return data unless data.is_a?(Hash) && data.key?(:data)

            collection = data[:data]
            return data unless collection.is_a?(ActiveRecord::Relation)

            page_params = state.request&.query&.dig(:page) || {}
            paginated, pagination_result = paginate(collection, state.schema_class, page_params)
            pagination_metadata = pagination_result[:pagination]

            data.merge(data: paginated, pagination: pagination_metadata)
          end

          def metadata(result, state)
            return {} unless result.is_a?(Hash) && result.key?(:pagination)

            { pagination: result[:pagination] }
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
