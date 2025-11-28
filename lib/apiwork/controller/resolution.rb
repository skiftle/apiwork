# frozen_string_literal: true

module Apiwork
  module Controller
    module Resolution
      extend ActiveSupport::Concern

      private

      def contract_class
        @contract_class ||= begin
          klass = api_class&.metadata&.resolve_contract_class(resource_metadata)
          klass || raise_contract_not_found_error
        end
      end

      def api_class
        @api_class ||= Apiwork::API.find(api_path) || raise_api_not_found_error
      end

      def api_path
        path_parts = request.path.split('/').reject(&:blank?)
        path_parts.empty? ? '/' : "/#{path_parts[0..1].join('/')}"
      end

      def adapter
        api_class.adapter
      end

      def resource_metadata
        @resource_metadata ||= api_class&.metadata&.resources&.[](resource_name)
      end

      def resource_name
        @resource_name ||= begin
          base_name = self.class.name.underscore.gsub('_controller', '').split('/').last
          resources = api_class&.metadata&.resources || {}

          plural = base_name.to_sym
          singular = base_name.singularize.to_sym

          resources.key?(plural) ? plural : singular
        end
      end

      def raise_api_not_found_error
        api_file = "config/apis/#{api_path.split('/').reject(&:blank?).join('_')}.rb"

        raise ConfigurationError,
              "No API found for #{self.class.name}. " \
              "Create the API: #{api_file} (Apiwork::API.draw '#{api_path}')"
      end

      def raise_contract_not_found_error
        resource_base = resource_name.to_s.singularize
        namespaces = api_class.metadata.namespaces

        contract_name = [*namespaces.map { |n| n.to_s.camelize }, "#{resource_base.camelize}Contract"].join('::')
        contract_path = ['app/contracts', *namespaces, "#{resource_base}_contract.rb"].join('/')

        raise ConfigurationError,
              "No contract found for #{self.class.name}. " \
              "Create the contract: #{contract_path} (#{contract_name})"
      end
    end
  end
end
