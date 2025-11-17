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
