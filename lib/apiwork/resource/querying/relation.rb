# frozen_string_literal: true

module Apiwork
  module Resource
    module Querying
      module Relation
        extend ActiveSupport::Concern

      class_methods do
        def query(scope, params)
          query_params = extract_query_params(params)

          scope = apply_filter(scope, query_params[:filter]) if query_params[:filter].present?

          sort_params = query_params[:sort] || default_sort
          scope = apply_sort(scope, sort_params) if sort_params.present?

          scope = apply_pagination(scope, query_params[:page]) if query_params[:page].present?

          scope
        rescue ArgumentError => e
          raise Apiwork::FilterError.new(
            code: :filter_error,
            detail: "Filter error: #{e.message}",
            path: [:filter]
          )
        rescue StandardError => e
          raise Apiwork::Error.new("Query error: #{e.message}")
        end

        def extract_query_params(params)
          if params.is_a?(ActionController::Parameters)
            params = params.dup.permit!.to_h.deep_symbolize_keys
          elsif params.respond_to?(:to_h)
            params = params.to_h.deep_symbolize_keys
          end

          {
            filter: params[:filter] || {},
            sort: params[:sort],
            page: params[:page] || {},
            include: params[:include]
          }
        end
      end
    end
  end
  end
end
