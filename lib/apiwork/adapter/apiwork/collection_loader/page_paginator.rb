# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class PagePaginator
          def self.perform(relation, schema_class, params)
            new(relation, schema_class, params).perform
          end

          def initialize(relation, schema_class, params)
            @relation = relation
            @schema_class = schema_class
            @params = params
          end

          def perform
            page_number = @params.fetch(:number, 1).to_i
            page_size = resolve_page_size
            offset = (page_number - 1) * page_size

            metadata = build_metadata(page_number, page_size)
            paginated_relation = @relation.limit(page_size).offset(offset)

            [paginated_relation, metadata]
          end

          private

          def resolve_page_size
            @params.fetch(:size, default_page_size).to_i
          end

          def default_page_size
            @schema_class.resolve_option(:default_page_size)
          end

          def build_metadata(page_number, page_size)
            items = count_items
            total = (items.to_f / page_size).ceil

            {
              pagination: {
                current: page_number,
                next: (page_number < total ? page_number + 1 : nil),
                prev: (page_number > 1 ? page_number - 1 : nil),
                total:,
                items:
              }
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
