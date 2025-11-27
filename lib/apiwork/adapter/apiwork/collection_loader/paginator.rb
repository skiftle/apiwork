# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class Paginator
          attr_reader :schema_class

          def self.perform(relation, schema_class, page_params)
            new(relation, schema_class).perform(page_params)
          end

          def initialize(relation, schema_class)
            @relation = relation
            @schema_class = schema_class
          end

          def perform(params)
            page_number = params.fetch(:number, 1).to_i
            page_size = params.fetch(:size, default_page_size).to_i
            offset = (page_number - 1) * page_size

            metadata = build_metadata(@relation, page_number, page_size)
            paginated_relation = @relation.limit(page_size).offset(offset)

            [paginated_relation, metadata]
          end

          def default_page_size
            schema_class.resolve_option(:default_page_size)
          end

          def max_page_size
            schema_class.resolve_option(:max_page_size)
          end

          private

          def build_metadata(scope, page_number, page_size)
            items = if scope.joins_values.any?
                      scope.except(:limit, :offset).distinct.count(:all)
                    else
                      scope.except(:limit, :offset).count
                    end
            total = (items.to_f / page_size).ceil

            page = {
              current: page_number,
              next: (page_number < total ? page_number + 1 : nil),
              prev: (page_number > 1 ? page_number - 1 : nil),
              total:,
              items:
            }

            {
              pagination: page
            }
          end
        end
      end
    end
  end
end
