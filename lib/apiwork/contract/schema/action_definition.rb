# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      module ActionDefinition
        def request_definition
          @request_definition
        end

        def response_definition
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
      end
    end
  end
end
