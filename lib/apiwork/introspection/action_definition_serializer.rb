# frozen_string_literal: true

module Apiwork
  module Introspection
    class ActionDefinitionSerializer
      def initialize(action_definition)
        @action_definition = action_definition
      end

      def serialize
        result = {
          summary: resolve_summary,
          description: resolve_description,
          tags: @action_definition.tags.presence,
          operation_id: @action_definition.operation_id,
          request: serialize_request(@action_definition.request_definition),
          response: serialize_response(@action_definition.response_definition),
          raises: raises.presence,
        }.compact

        result[:deprecated] = true if @action_definition.deprecated

        result
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
        return nil unless contract_class.name

        contract_name = contract_class.name.demodulize.delete_suffix('Contract').underscore
        action_name = @action_definition.action_name

        contract_class.api_class.structure.i18n_lookup(:contracts, contract_name, :actions, action_name, field)
      end

      def serialize_request(request_definition)
        return nil unless request_definition

        {
          query: request_definition.query_param_definition&.then { ParamDefinitionSerializer.new(_1).serialize },
          body: request_definition.body_param_definition&.then { ParamDefinitionSerializer.new(_1).serialize },
        }.compact.presence
      end

      def serialize_response(response_definition)
        return nil unless response_definition
        return { no_content: true } if response_definition.no_content?

        body_param_definition = response_definition.body_param_definition
        return nil unless body_param_definition

        result_wrapper = response_definition.result_wrapper
        serialized = ParamDefinitionSerializer.new(body_param_definition, result_wrapper:).serialize
        { body: serialized }.compact.presence
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
        api_class = @action_definition.contract_class.api_class
        return nil unless api_class

        contract_class = @action_definition.contract_class
        resource = api_class.structure.find_resource { |r| r.contract_class == contract_class }
        return nil unless resource

        resource.actions[@action_definition.action_name.to_sym]&.method
      end
    end
  end
end
