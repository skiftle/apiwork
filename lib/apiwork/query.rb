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
      @result = apply_pagination(@result, @params[:page]) if @params[:page].present?

      # Smart includes - merges serializable, filter, sort, and explicit includes
      @result = apply_includes(@result, @params)

      # Always build meta for pagination info
      @meta = build_meta(@result)

      self
    end
  end
end
