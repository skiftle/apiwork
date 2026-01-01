# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      class CollectionLoader
        attr_reader :schema_class

        def self.load(collection, schema_class, render_state)
          new(collection, schema_class, render_state).load
        end

        def initialize(collection, schema_class, render_state)
          @schema_class = schema_class
          @render_state = render_state
          @collection = collection
          @result_metadata = {}
        end

        def load
          return { data: @collection, metadata: {} } unless @render_state.action.index?
          return { data: @collection, metadata: {} } unless @collection.is_a?(ActiveRecord::Relation)

          params = @render_state.query.slice(:filter, :include, :page, :sort)

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
