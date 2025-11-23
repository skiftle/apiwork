# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class Query
        module Pagination
          def apply_pagination(scope, params)
            page_number = params.fetch(:number, 1).to_i
            page_size = params.fetch(:size, default_page_size).to_i
            offset = (page_number - 1) * page_size

            @meta = build_meta_for_scope(scope, page_number, page_size)

            scope.limit(page_size).offset(offset)
          end

          def build_meta(collection)
            return @meta if @meta.present?

            build_meta_for_scope(collection, 1, default_page_size)
          end

          def default_page_size
            schema.default_page_size
          end

          def max_page_size
            schema.max_page_size
          end

          private

          def build_meta_for_scope(scope, page_number, page_size)
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
              pagination: transform_keys(page)
            }
          end

          def transform_keys(hash)
            case schema.output_key_format
            when :camel
              hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
            when :underscore
              hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
            else
              hash
            end
          end
        end
      end
    end
  end
end
