# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      class CollectionLoader
        attr_reader :schema_class

        def self.load(collection, schema_class, action_data)
          new(collection, schema_class, action_data).load
        end

        def initialize(collection, schema_class, action_data)
          @schema_class = schema_class
          @action_data = action_data
          @collection = collection
          @result_metadata = {}
        end

        def load
          return { data: @collection, metadata: {} } unless @action_data.index?
          return { data: @collection, metadata: {} } unless @collection.is_a?(ActiveRecord::Relation)

          params = @action_data.query.slice(:filter, :sort, :page, :include)

          issues = []

          @collection = Filter.filter(@collection, @schema_class, params[:filter], issues) if params[:filter].present?

          @collection = Sorter.sort(@collection, @schema_class, params[:sort], issues)

          raise ContractError, issues if issues.any?

          @collection = EagerLoader.load(@collection, @schema_class, params)

          @collection, pagination_metadata = Paginator.paginate(@collection, @schema_class, params[:page] || {})
          @result_metadata.merge!(pagination_metadata)

          { data: @collection, metadata: @result_metadata }
        end
      end
    end
  end
end
