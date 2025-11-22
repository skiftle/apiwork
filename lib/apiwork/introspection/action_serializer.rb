# frozen_string_literal: true

module Apiwork
  module Introspection
    class ActionSerializer
      def initialize(action_definition)
        @action_definition = action_definition
      end

      def serialize
        result = {}

        input_def = @action_definition.merged_input_definition
        result[:input] = input_def ? DefinitionSerializer.new(input_def).serialize : nil

        output_def = @action_definition.merged_output_definition
        result[:output] = output_def ? DefinitionSerializer.new(output_def).serialize : nil

        result[:error_codes] = error_codes

        result
      end

      private

      def error_codes
        action_codes = @action_definition.instance_variable_get(:@error_codes) || []
        auto_codes = auto_writable_error_codes

        (action_codes + auto_codes).uniq.sort
      end

      def auto_writable_error_codes
        return [] unless @action_definition.contract_class.schema?

        action_name_sym = @action_definition.action_name.to_sym
        return [422] if [:create, :update].include?(action_name_sym)

        return [] if [:index, :show, :destroy].include?(action_name_sym)

        http_method = find_http_method
        return [] unless http_method

        [:post, :patch, :put].include?(http_method) ? [422] : []
      end

      def find_http_method
        return nil unless @action_definition.respond_to?(:find_api_for_contract, true)

        api = @action_definition.send(:find_api_for_contract)
        return nil unless api&.metadata

        action_name_sym = @action_definition.action_name.to_sym
        api.metadata.search_resources do |resource_metadata|
          next unless @action_definition.send(:resource_uses_contract?, resource_metadata, @action_definition.contract_class)

          return resource_metadata[:members][action_name_sym][:method] if resource_metadata[:members]&.key?(action_name_sym)

          resource_metadata[:collections][action_name_sym][:method] if resource_metadata[:collections]&.key?(action_name_sym)
        end
      end
    end
  end
end
