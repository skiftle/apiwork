# frozen_string_literal: true

require_relative 'query/filtering'
require_relative 'query/sorting'
require_relative 'query/pagination'
require_relative 'query/eager_loading'

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
      @params = extract_query_params(params)

      @result = apply_filter(@result, @params[:filter]) if @params[:filter].present?
      @result = apply_sort(@result, @params[:sort])

      # Apply pagination and build meta
      if @params[:page].present?
        @result = apply_pagination(@result, @params[:page])
      end

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

    private

    def extract_query_params(params)
      {
        filter: params[:filter],
        sort: params[:sort],
        page: params[:page],
        include: params[:include]
      }
    end
  end
end
