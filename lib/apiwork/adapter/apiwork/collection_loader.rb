# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        attr_reader :schema_class

        def self.load(collection, schema_class, action_data)
          new(collection, schema_class, action_data).load
        end

        def initialize(collection, schema_class, action_data)
          @schema_class = schema_class
          @action_data = action_data
          @data = collection
          @metadata = {}
        end

        def load
          return { data: @data, metadata: {} } unless @action_data.index?
          return { data: @data, metadata: {} } unless @data.is_a?(ActiveRecord::Relation)

          params = @action_data.query.slice(:filter, :sort, :page, :include)

          issues = []

          @data = Filter.perform(@data, @schema_class, params[:filter], issues) if params[:filter].present?

          @data = Sorter.perform(@data, @schema_class, params[:sort], issues)

          raise ConstraintError, issues if issues.any?

          @data = EagerLoader.perform(@data, @schema_class, params)

          @data, pagination_metadata = Paginator.perform(@data, @schema_class, params[:page] || {})
          @metadata.merge!(pagination_metadata)

          { data: @data, metadata: @metadata }
        end
      end
    end
  end
end
