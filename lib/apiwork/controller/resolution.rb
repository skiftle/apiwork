# frozen_string_literal: true

module Apiwork
  module Controller
    module Resolution
      extend ActiveSupport::Concern

      included do
        before_action :set_current_contract
      end

      private

      def set_current_contract
        contract = current_api&.metadata&.resolve_contract_class(resource_metadata)
        @current_contract = contract || raise_contract_not_found_error
      end

      def current_contract
        @current_contract
      end

      def current_api
        @current_api ||= Apiwork::API.find(api_path)
      end

      def api_path
        path_parts = request.path.split('/').reject(&:blank?)
        path_parts.empty? ? '/' : "/#{path_parts[0..1].join('/')}"
      end

      def adapter
        current_api.adapter
      end

      def resource_metadata
        @resource_metadata ||= current_api&.metadata&.resources&.[](resource_name)
      end

      def resource_name
        @resource_name ||= begin
          base_name = self.class.name.underscore.gsub('_controller', '').split('/').last
          resources = current_api&.metadata&.resources || {}

          plural = base_name.to_sym
          singular = base_name.singularize.to_sym

          resources.key?(plural) ? plural : singular
        end
      end

      def raise_contract_not_found_error
        raise ConfigurationError,
              "No contract found for #{self.class.name}. " \
              'Ensure the resource is defined in the API and has a contract.'
      end
    end
  end
end
