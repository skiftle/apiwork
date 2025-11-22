# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      module ActionDefinition
        def request_definition
          auto_generate_request_if_needed
          @request_definition
        end

        def response_definition
          auto_generate_response_if_needed
          @response_definition
        end

        def merges_request?
          return false if resets_request?

          true
        end

        def merges_response?
          return false if resets_response?

          true
        end

        def request(replace: false, &block)
          @reset_request = replace if replace

          @request_definition ||= RequestDefinition.new(
            contract_class: contract_class,
            action_name: action_name
          )

          @request_definition.instance_eval(&block) if block

          @request_definition
        end

        def response(replace: false, &block)
          @reset_response = replace if replace

          @response_definition ||= ResponseDefinition.new(
            contract_class: contract_class,
            action_name: action_name
          )

          @response_definition.instance_eval(&block) if block

          @response_definition
        end

        def is_destroy_action?
          action_name.to_sym == :destroy
        end

        def serialize_data(data, context: {}, includes: nil)
          needs_serialization = if data.is_a?(Hash)
                                  false
                                elsif data.is_a?(Array)
                                  data.empty? || data.first.class != Hash
                                else
                                  true
                                end

          needs_serialization ? contract_class.schema_class.serialize(data, context: context, includes: includes) : data
        end

        def auto_generate_request_if_needed
          return if @auto_generated_request
          return if @reset_request

          @auto_generated_request = true

          schema_class = contract_class.schema_class
          @request_definition ||= RequestDefinition.new(
            contract_class: contract_class,
            action_name: action_name
          )

          case action_name.to_sym
          when :index
            @request_definition.query { RequestGenerator.generate_query_params(self, schema_class) }
          when :show
            add_include_query_param_if_needed(@request_definition, schema_class)
          when :create
            @request_definition.body { RequestGenerator.generate_writable_input(self, schema_class, :create) }
            add_include_query_param_if_needed(@request_definition, schema_class)
          when :update
            @request_definition.body { RequestGenerator.generate_writable_input(self, schema_class, :update) }
            add_include_query_param_if_needed(@request_definition, schema_class)
          when :destroy
            # Destroy actions have no request params beyond routing params
          else
            add_include_query_param_if_needed(@request_definition, schema_class) if member_action?
          end
        end

        def add_include_query_param_if_needed(request_def, schema_class)
          return unless schema_class.association_definitions.any?

          include_type = TypeBuilder.build_include_type(contract_class, schema_class)
          request_def.query { param :include, type: include_type, required: false }
        end

        def auto_generate_response_if_needed
          return if @auto_generated_response
          return if @reset_response

          @auto_generated_response = true

          schema_class = contract_class.schema_class
          @response_definition ||= ResponseDefinition.new(
            contract_class: contract_class,
            action_name: action_name
          )

          case action_name.to_sym
          when :index
            @response_definition.body { ResponseGenerator.generate_collection_output(self, schema_class) }
          when :show, :create, :update
            @response_definition.body { ResponseGenerator.generate_single_output(self, schema_class) }
          when :destroy
            # Destroy actions return no response body (HTTP 204)
          else
            if collection_action?
              @response_definition.body { ResponseGenerator.generate_collection_output(self, schema_class) }
            elsif member_action?
              @response_definition.body { ResponseGenerator.generate_single_output(self, schema_class) }
            end
          end
        end

        def collection_action?
          return true if action_name.to_sym == :index

          api = find_api_for_contract
          return false unless api&.metadata

          api.metadata.search_resources do |resource_metadata|
            next unless resource_uses_contract?(resource_metadata, contract_class)

            true if resource_metadata[:collections]&.key?(action_name.to_sym)
          end || false
        end

        def member_action?
          return true if %i[show create update].include?(action_name.to_sym)

          api = find_api_for_contract
          return false unless api&.metadata

          api.metadata.search_resources do |resource_metadata|
            next unless resource_uses_contract?(resource_metadata, contract_class)

            true if resource_metadata[:members]&.key?(action_name.to_sym)
          end || false
        end

        def find_api_for_contract
          Apiwork::API.all.find do |api_class|
            next unless api_class.metadata

            api_class.metadata.search_resources { |resource| resource_uses_contract?(resource, contract_class) }
          end
        end

        def resource_uses_contract?(resource_metadata, contract)
          matches_contract_option?(resource_metadata, contract) ||
            matches_schema_contract?(resource_metadata, contract)
        end

        def matches_contract_option?(resource_metadata, contract)
          contract_class = resource_metadata[:contract_class]
          return false unless contract_class

          contract_class == contract
        end

        def matches_schema_contract?(resource_metadata, contract)
          schema_class = resource_metadata[:schema_class]
          return false unless schema_class
          return false unless contract.schema_class

          schema_class == contract.schema_class
        end
      end
    end
  end
end
