# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionLoader
        include Filtering
        include Sorting
        include Pagination
        include EagerLoading

        attr_reader :params,
                    :schema_class

        def self.load(collection, schema_class, query, context)
          new(collection, schema_class, query, context).load
        end

        def initialize(collection, schema_class, query, context)
          @collection = collection
          @schema_class = schema_class
          @query = query
          @context = context
          @data = collection
          @metadata = {}
        end

        def load
          return LoadResult.new(@collection) unless @context.index?
          return LoadResult.new(@collection) unless @collection.is_a?(ActiveRecord::Relation)

          @params = @query.slice(:filter, :sort, :page, :include)

          issues = []

          @data = apply_filter(@data, @params[:filter], issues) if @params[:filter].present?

          @data = apply_sort(@data, @params[:sort], issues)

          @data = apply_pagination(@data, @params[:page]) if @params[:page].present?

          raise QueryError, issues if issues.any?

          @data = apply_includes(@data, @params)

          @metadata = build_meta(@data)

          LoadResult.new(@data, @metadata)
        end
      end
    end
  end
end
