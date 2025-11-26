# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionLoader
        include Filtering
        include Sorting
        include Pagination
        include EagerLoading

        attr_reader :schema_class

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
          return { data: @collection, metadata: {} } unless @context.index?
          return { data: @collection, metadata: {} } unless @collection.is_a?(ActiveRecord::Relation)

          params = @query.slice(:filter, :sort, :page, :include)

          issues = []

          @data = apply_filter(@data, params[:filter], issues) if params[:filter].present?

          @data = apply_sort(@data, params[:sort], issues)

          @data = apply_pagination(@data, params[:page]) if params[:page].present?

          raise QueryError, issues if issues.any?

          @data = apply_includes(@data, params)

          @metadata = build_meta(@data)

          { data: @data, metadata: @metadata }
        end
      end
    end
  end
end
