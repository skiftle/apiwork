# frozen_string_literal: true

module Apiwork
  class Query
    include Filtering
    include Sorting
    include Pagination
    include EagerLoading

    attr_reader :scope, :schema, :params, :result, :meta

    def initialize(scope, schema:)
      @scope = scope
      @schema = schema
      @result = scope
      @meta = {}
    end

    def perform(params)
      @params = params.slice(:filter, :sort, :page, :include)

      @result = apply_filter(@result, @params[:filter]) if @params[:filter].present?
      @result = apply_sort(@result, @params[:sort])

      # Apply pagination and build meta
      @result = apply_pagination(@result, @params[:page]) if @params[:page].present?

      # Apply includes if explicitly requested or if auto_include_associations is enabled
      if @params[:include].present?
        @result = apply_includes(@result, @params[:include])
      elsif schema.auto_include_associations
        @result = apply_includes(@result)
      end

      # Always build meta for the final result (for pagination info)
      @meta = build_meta(@result)

      self
    end
  end
end
