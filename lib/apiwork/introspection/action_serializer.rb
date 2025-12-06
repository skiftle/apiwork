# frozen_string_literal: true

module Apiwork
  module Introspection
    class ActionSerializer
      def initialize(action_definition)
        @action_definition = action_definition
      end

      def serialize
        result = {}

        result[:summary] = resolve_summary
        result[:description] = resolve_description
        result[:tags] = @action_definition.tags
        result[:deprecated] = @action_definition.deprecated
        result[:operation_id] = @action_definition.operation_id

        request_definition = @action_definition.request_definition
        result[:request] = serialize_request(request_definition) if request_definition

        response_definition = @action_definition.response_definition
        result[:response] = serialize_response(response_definition) if response_definition

        result[:raises] = raises

        result.compact
      end

      private

      def resolve_summary
        return @action_definition.summary if @action_definition.summary

        i18n_lookup(:summary)
      end

      def resolve_description
        return @action_definition.description if @action_definition.description

        i18n_lookup(:description)
      end

      def i18n_lookup(field)
        contract_class = @action_definition.contract_class
        api_class = contract_class.api_class
        return nil unless api_class&.metadata&.path && contract_class.name

        contract_name = contract_class.name.demodulize.underscore.gsub(/_contract$/, '')
        action_name = @action_definition.action_name

        api_class.metadata.i18n_lookup(:contracts, contract_name, :actions, action_name, field)
      end

      def serialize_request(request_definition)
        result = {}

        query_definition = request_definition.query_definition
        result[:query] = DefinitionSerializer.new(query_definition).serialize if query_definition

        body_definition = request_definition.body_definition
        result[:body] = DefinitionSerializer.new(body_definition).serialize if body_definition

        result.presence
      end

      def serialize_response(response_definition)
        result = {}

        body_definition = response_definition.body_definition
        result[:body] = DefinitionSerializer.new(body_definition).serialize if body_definition

        result.presence
      end

      def raises
        action_codes = @action_definition.instance_variable_get(:@raises) || []
        auto_codes = auto_raises
        (action_codes + auto_codes).uniq.sort_by(&:to_s)
      end

      def auto_raises
        return [] unless @action_definition.contract_class.schema?

        action_name = @action_definition.action_name.to_sym
        return [:unprocessable_entity] if [:create, :update].include?(action_name)

        return [] if [:index, :show, :destroy].include?(action_name)

        http_method = find_http_method
        return [] unless http_method

        [:post, :patch, :put].include?(http_method) ? [:unprocessable_entity] : []
      end

      def find_http_method
        return nil unless @action_definition.respond_to?(:find_api_for_contract, true)

        api_class = @action_definition.send(:find_api_for_contract)
        return nil unless api_class&.metadata

        action_name = @action_definition.action_name.to_sym
        api_class.metadata.search_resources do |resource_metadata|
          next unless @action_definition.send(:resource_uses_contract?, resource_metadata, @action_definition.contract_class)

          method = resource_metadata.dig(:members, action_name, :method)
          return method if method

          resource_metadata.dig(:collections, action_name, :method)
        end
      end
    end
  end
end
