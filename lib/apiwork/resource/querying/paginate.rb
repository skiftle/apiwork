# frozen_string_literal: true

module Apiwork
  module Resource
    module Querying
      module Paginate
        extend ActiveSupport::Concern

        class_methods do
          def apply_pagination(scope, params)
            page_number = params.fetch(:number, 1).to_i
            page_size = params.fetch(:size, default_page_size).to_i

            if page_number < 1
              error = ArgumentError.new('page[number] must be >= 1')
              Errors::Handler.handle(error, context: { page_number: page_number })
              page_number = 1
            end

            if page_size < 1
              error = ArgumentError.new('page[size] must be >= 1')
              Errors::Handler.handle(error, context: { page_size: page_size })
              page_size = default_page_size
            end

            page_size = [page_size, maximum_page_size].min

            scope.instance_variable_set(:@pagination_page, page_number)
            scope.instance_variable_set(:@pagination_size, page_size)

            offset = (page_number - 1) * page_size

            scope.limit(page_size).offset(offset)
          end

          def build_meta(collection)
            current = collection.instance_variable_get(:@pagination_page) || 1
            size = collection.instance_variable_get(:@pagination_size) || default_page_size

            items = collection.except(:limit, :offset).count
            total = (items.to_f / size).ceil

            page = {
              current:,
              next: (current < total ? current + 1 : nil),
              prev: (current > 1 ? current - 1 : nil),
              total:,
              items:
            }

            {
              page: Apiwork::Transform::Case.hash(page, serialize_key_transform)
            }
          end

          def default_page_size
            @default_page_size || Apiwork.configuration.default_page_size
          end

          def maximum_page_size
            @maximum_page_size || Apiwork.configuration.maximum_page_size
          end
        end
      end
    end
  end
end
