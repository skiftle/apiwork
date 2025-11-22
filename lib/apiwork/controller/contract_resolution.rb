# frozen_string_literal: true

module Apiwork
  module Controller
    module ContractResolution
      extend ActiveSupport::Concern

      included do
        before_action :set_current_contract
      end

      private

      def set_current_contract
        @current_contract = resolve_contract_from_metadata || infer_contract_class || raise_no_contract_class_error
      end

      def current_contract
        @current_contract
      end

      def resolve_contract_from_metadata
        api_path = extract_api_path_from_request
        return nil unless api_path

        api = Apiwork::API.find(api_path)
        return nil unless api

        resource_name = extract_resource_name_from_controller
        resource_metadata = api.metadata.resources[resource_name]
        return nil unless resource_metadata

        resource_metadata[:contract_class]
      end

      def extract_api_path_from_request
        path_parts = request.path.split('/').reject(&:blank?)
        return '/' if path_parts.empty?

        "/#{path_parts[0..1].join('/')}"
      end

      def extract_resource_name_from_controller
        controller_path = self.class.name.underscore.gsub('_controller', '')
        parts = controller_path.split('/')
        parts.last.pluralize.to_sym
      end

      def infer_contract_class
        contract_name = "#{self.class.name.sub(/Controller$/, '').singularize}Contract"
        contract_name.constantize
      rescue NameError
        nil
      end

      def raise_no_contract_class_error
        contract_class_name = "#{self.class.name.sub(/Controller$/, '').singularize}Contract"

        raise ConfigurationError, "No contract found for #{self.class.name}. " \
                                  "Expected #{contract_class_name} to be defined."
      end
    end
  end
end
