# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        attr_reader :schema_class

        def self.load(collection, schema_class, query, action_data)
          new(collection, schema_class, query, action_data).load
        end

        def initialize(collection, schema_class, query, action_data)
          @collection = collection
          @schema_class = schema_class
          @query = query
          @action_data = action_data
          @data = collection
          @metadata = {}
        end

        def load
          return { data: @collection, metadata: {} } unless @action_data.index?
          return { data: @collection, metadata: {} } unless @collection.is_a?(ActiveRecord::Relation)

          params = @query.slice(:filter, :sort, :page, :include)

          issues = []

          @data = Filter.perform(@data, @schema_class, params[:filter], issues) if params[:filter].present?

          @data = Sorter.perform(@data, @schema_class, params[:sort], issues)

          @data, pagination_metadata = Paginator.perform(@data, @schema_class, params[:page] || {})
          @metadata.merge!(pagination_metadata)

          raise ConstraintError, issues if issues.any?

          @data = EagerLoader.perform(@data, @schema_class, params)

          { data: @data, metadata: @metadata }
        end
      end
    end
  end
end
