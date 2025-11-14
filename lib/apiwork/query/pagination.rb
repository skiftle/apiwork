# frozen_string_literal: true

module Apiwork
  class Query
    module Pagination
      def apply_pagination(scope, params)
        page_number = params.fetch(:number, 1).to_i
        page_size = params.fetch(:size, default_page_size).to_i

        if page_number < 1
          error = Apiwork::QueryError.new('page[number] must be >= 1')
          Errors::Handler.handle(error, context: { page_number: page_number })
        end

        if page_size < 1
          error = Apiwork::QueryError.new('page[size] must be >= 1')
          Errors::Handler.handle(error, context: { page_size: page_size })
        end

        if page_size > maximum_page_size
          error = Apiwork::QueryError.new("page[size] must be <= #{maximum_page_size}")
          Errors::Handler.handle(error, context: { page_size: page_size, maximum: maximum_page_size })
        end

        page_size = [page_size, maximum_page_size].min
        offset = (page_number - 1) * page_size

        # Build metadata immediately
        @meta = build_meta_for_scope(scope, page_number, page_size)

        scope.limit(page_size).offset(offset)
      end

      def build_meta(collection)
        # Return existing meta if pagination was applied
        return @meta if @meta.present?

        # No pagination params provided - build default pagination meta
        # Treat as page 1 with default page size
        build_meta_for_scope(collection, 1, default_page_size)
      end

      def default_page_size
        schema.default_page_size || Apiwork.configuration.default_page_size
      end

      def maximum_page_size
        schema.maximum_page_size || Apiwork.configuration.maximum_page_size
      end

      private

      def build_meta_for_scope(scope, page_number, page_size)
        items = scope.except(:limit, :offset).count
        total = (items.to_f / page_size).ceil

        page = {
          current: page_number,
          next: (page_number < total ? page_number + 1 : nil),
          prev: (page_number > 1 ? page_number - 1 : nil),
          total:,
          items:
        }

        {
          page: Apiwork::Transform::Case.hash(page, schema.serialize_key_transform)
        }
      end
    end
  end
end
