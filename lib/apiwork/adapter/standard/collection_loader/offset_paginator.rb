# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class CollectionLoader
        class OffsetPaginator
          def self.paginate(relation, schema_class, params)
            new(relation, schema_class, params).paginate
          end

          def initialize(relation, schema_class, params)
            @relation = relation
            @schema_class = schema_class
            @params = params
          end

          def paginate
            page_number = @params.fetch(:number, 1).to_i
            limit = resolve_limit
            offset = (page_number - 1) * limit

            metadata = build_metadata(page_number, limit)
            paginated_relation = @relation.limit(limit).offset(offset)

            [paginated_relation, metadata]
          end

          private

          def resolve_limit
            [@params.fetch(:size, default_limit).to_i, 1].max
          end

          def default_limit
            @schema_class.resolve_option(:pagination, :default_size)
          end

          def build_metadata(page_number, limit)
            items = count_items
            total = (items.to_f / limit).ceil

            {
              pagination: {
                items:,
                total:,
                current: page_number,
                next: (page_number < total ? page_number + 1 : nil),
                prev: (page_number > 1 ? page_number - 1 : nil),
              },
            }
          end

          def count_items
            count_result = if @relation.joins_values.any?
                             @relation.except(:limit, :offset, :group).distinct.count(:all)
                           else
                             @relation.except(:limit, :offset, :group).count
                           end

            count_result.is_a?(Hash) ? count_result.size : count_result
          end
        end
      end
    end
  end
end
