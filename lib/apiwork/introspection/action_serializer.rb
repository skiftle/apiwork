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

        request_def = @action_definition.request_definition
        result[:request] = serialize_request(request_def) if request_def

        response_def = @action_definition.response_definition
        result[:response] = serialize_response(response_def) if response_def

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

        api_path = api_class.metadata.locale_key
        contract_name = contract_class.name.demodulize.underscore.gsub(/_contract$/, '')
        action_name = @action_definition.action_name

        key = :"apiwork.apis.#{api_path}.contracts.#{contract_name}.actions.#{action_name}.#{field}"
        I18n.t(key, default: nil)
      end

      def serialize_request(request_def)
        result = {}

        query_def = request_def.query_definition
        result[:query] = DefinitionSerializer.new(query_def).serialize if query_def

        body_def = request_def.body_definition
        result[:body] = DefinitionSerializer.new(body_def).serialize if body_def

        result.presence
      end

      def serialize_response(response_def)
        result = {}

        body_def = response_def.body_definition
        result[:body] = DefinitionSerializer.new(body_def).serialize if body_def

        result.presence
      end

      def raises
        action_codes = @action_definition.instance_variable_get(:@raises) || []
        auto_codes = auto_raises
        (action_codes + auto_codes).uniq.sort_by(&:to_s)
      end

      def auto_raises
        return [] unless @action_definition.contract_class.schema?

        action_name_sym = @action_definition.action_name.to_sym
        return [:unprocessable_entity] if [:create, :update].include?(action_name_sym)

        return [] if [:index, :show, :destroy].include?(action_name_sym)

        http_method = find_http_method
        return [] unless http_method

        [:post, :patch, :put].include?(http_method) ? [:unprocessable_entity] : []
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
