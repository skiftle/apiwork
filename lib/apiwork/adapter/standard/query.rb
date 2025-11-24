# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class Query
        include Filtering
        include Sorting
        include Pagination
        include EagerLoading

        attr_reader :meta,
                    :params,
                    :result,
                    :schema_class,
                    :scope

        def initialize(scope, schema_class)
          @scope = scope
          @schema_class = schema_class
          @result = scope
          @meta = {}
        end

        def perform(params)
          @params = params.slice(:filter, :sort, :page, :include)

          issues = []

          @result = apply_filter(@result, @params[:filter], issues) if @params[:filter].present?

          @result = apply_sort(@result, @params[:sort], issues)

          @result = apply_pagination(@result, @params[:page]) if @params[:page].present?

          raise QueryError, issues if issues.any?

          @result = apply_includes(@result, @params)

          @meta = build_meta(@result)

          self
        end
      end
    end
  end
end
