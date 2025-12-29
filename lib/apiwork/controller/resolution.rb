# frozen_string_literal: true

module Apiwork
  module Controller
    module Resolution
      extend ActiveSupport::Concern

      private

      def contract_class
        @contract_class ||= begin
          klass = resource&.resolve_contract_class
          klass || raise_contract_not_found_error
        end
      end

      def api_class
        @api_class ||= find_api_class || raise_api_not_found_error
      end

      def api_path
        api_class.path
      end

      def relative_path
        request.path.delete_prefix(api_path)
      end

      def adapter
        api_class.adapter
      end

      def resource
        @resource ||= api_class.structure.find_resource(resource_name)
      end

      def raise_api_not_found_error
        path = path_parts.empty? ? '/' : "/#{path_parts[0..1].join('/')}"
        api_file = "config/apis/#{path.split('/').reject(&:blank?).join('_')}.rb"

        raise ConfigurationError,
              "No API found for #{self.class.name}. " \
              "Create the API: #{api_file} (Apiwork::API.define '#{path}')"
      end

      def raise_contract_not_found_error
        resource_base = resource_name.to_s.singularize
        namespaces = api_class.structure.namespaces

        contract_name = [*namespaces.map { |n| n.to_s.camelize }, "#{resource_base.camelize}Contract"].join('::')
        contract_path = ['app/contracts', *namespaces, "#{resource_base}_contract.rb"].join('/')

        raise ConfigurationError,
              "No contract found for #{self.class.name}. " \
              "Create the contract: #{contract_path} (#{contract_name})"
      end

      def find_api_class
        parts = path_parts
        return API.find('/') if parts.empty?

        (parts.length - 1).downto(1) do |i|
          path = "/#{parts[0...i].join('/')}"
          api_class = API.find(path)
          return api_class if api_class
        end

        nil
      end

      def resource_name
        @resource_name ||= begin
          base_name = self.class.name.underscore.delete_suffix('_controller').split('/').last

          plural = base_name.to_sym
          singular = base_name.singularize.to_sym

          api_class.structure.find_resource(plural) ? plural : singular
        end
      end

      def path_parts
        @path_parts ||= request.path.split('/').reject(&:blank?)
      end
    end
  end
end
