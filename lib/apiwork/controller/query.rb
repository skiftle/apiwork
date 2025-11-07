# frozen_string_literal: true

module Apiwork
  module Controller
    module Query
      extend ActiveSupport::Concern

      def query(scope)
        # Go through Contract → Schema
        contract = Contract::Resolver.call(
          controller_class: self.class,
          action_name: action_name,
          metadata: find_action_metadata
        )

        raise ConfigurationError, "Contract #{contract.class.name} must declare schema" unless contract.class.schema?
        schema_class = contract.class.schema_class

        # Use new Query class
        query_params = extract_query_params(action_params)
        query = Apiwork::Query.new(scope, schema: schema_class).perform(query_params)

        # Store pagination metadata
        @pagination_meta = query.meta if query.meta.present?

        query.result
      end

      def pagination_meta
        @pagination_meta
      end

      private

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
