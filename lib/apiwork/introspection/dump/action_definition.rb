# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class ActionDefinition
        def initialize(action_definition)
          @action_definition = action_definition
        end

        def to_h
          {
            deprecated: @action_definition.deprecated == true,
            description: @action_definition.description || i18n_lookup(:description),
            operation_id: @action_definition.operation_id,
            raises: raises,
            request: build_request(@action_definition.request_definition),
            response: build_response(@action_definition.response_definition),
            summary: @action_definition.summary || i18n_lookup(:summary),
            tags: @action_definition.tags || [],
          }
        end

        private

        def i18n_lookup(field)
          contract_class = @action_definition.contract_class
          return nil unless contract_class.name

          contract_name = contract_class.name.demodulize.delete_suffix('Contract').underscore
          action_name = @action_definition.action_name

          contract_class.api_class.structure.i18n_lookup(:contracts, contract_name, :actions, action_name, field)
        end

        def build_request(request_definition)
          return { body: {}, query: {} } unless request_definition

          {
            body: build_param_definition(request_definition.body_param_definition),
            query: build_param_definition(request_definition.query_param_definition),
          }
        end

        def build_param_definition(param_definition)
          param_definition ? ParamDefinition.new(param_definition).to_h : {}
        end

        def build_response(response_definition)
          return { body: {}, no_content: false } unless response_definition
          return { body: {}, no_content: true } if response_definition.no_content?

          body_param_definition = response_definition.body_param_definition
          return { body: {}, no_content: false } unless body_param_definition

          result_wrapper = response_definition.result_wrapper
          dumped = ParamDefinition.new(body_param_definition, result_wrapper:).to_h
          { body: dumped, no_content: false }
        end

        def raises
          action_error_codes = @action_definition.instance_variable_get(:@raises) || []
          api_error_codes = api_level_raises
          auto_error_codes = auto_raises
          (api_error_codes + action_error_codes + auto_error_codes).uniq.sort_by(&:to_s)
        end

        def api_level_raises
          api_class = @action_definition.contract_class.api_class
          return [] unless api_class

          api_class.structure.raises || []
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
          resource = api_class.structure.find_resource { |resource| resource.contract_class == contract_class }
          return nil unless resource

          resource.actions[@action_definition.action_name.to_sym]&.method
        end
      end
    end
  end
end
