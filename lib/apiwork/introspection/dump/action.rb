# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Action
        def initialize(contract_action)
          @contract_action = contract_action
        end

        def to_h
          {
            deprecated: @contract_action.deprecated?,
            description: @contract_action.description || i18n_lookup(:description),
            operation_id: @contract_action.operation_id,
            raises: raises,
            request: build_request(@contract_action.request),
            response: build_response(@contract_action.response),
            summary: @contract_action.summary || i18n_lookup(:summary),
            tags: @contract_action.tags || [],
          }
        end

        private

        def i18n_lookup(field)
          contract_class = @contract_action.contract_class
          return nil unless contract_class.name

          contract_class.api_class.translate(
            :contracts,
            contract_class.name.demodulize.delete_suffix('Contract').underscore,
            :actions,
            @contract_action.name,
            field,
          )
        end

        def build_request(request)
          return { body: {}, query: {} } unless request

          {
            body: build_param(request.body),
            query: build_param(request.query),
          }
        end

        def build_param(param)
          param ? Param.new(param).to_h : {}
        end

        def build_response(response)
          return { body: {}, no_content: false } unless response
          return { body: {}, no_content: true } if response.no_content?

          body_shape = response.body
          return { body: {}, no_content: false } unless body_shape

          { body: Param.new(body_shape, result_wrapper: response.result_wrapper).to_h, no_content: false }
        end

        def raises
          action_error_codes = @contract_action.raises
          api_error_codes = api_level_raises
          auto_error_codes = auto_raises
          (api_error_codes + action_error_codes + auto_error_codes).uniq.sort_by(&:to_s)
        end

        def api_level_raises
          api_class = @contract_action.contract_class.api_class
          return [] unless api_class

          api_class.raises
        end

        def auto_raises
          return [] unless @contract_action.contract_class.representation?

          action_name = @contract_action.name.to_sym
          return [:unprocessable_entity] if [:create, :update].include?(action_name)

          return [] if [:index, :show, :destroy].include?(action_name)

          http_method = find_http_method
          return [] unless http_method

          [:post, :patch, :put].include?(http_method) ? [:unprocessable_entity] : []
        end

        def find_http_method
          api_class = @contract_action.contract_class.api_class
          return nil unless api_class

          contract_class = @contract_action.contract_class
          resource = api_class.structure.find_resource { |resource| resource.contract_class == contract_class }
          return nil unless resource

          resource.actions[@contract_action.name.to_sym]&.method
        end
      end
    end
  end
end
