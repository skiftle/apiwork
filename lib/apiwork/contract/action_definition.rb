# frozen_string_literal: true

module Apiwork
  module Contract
    class ActionDefinition
      attr_reader :action_name,
                  :contract_class,
                  :request_definition,
                  :response_definition

      def initialize(action_name:, contract_class:, replace: false)
        @action_name = action_name
        @contract_class = contract_class
        @reset_request = replace
        @reset_response = replace
        @request_definition = nil
        @response_definition = nil
        @raises = []
        @summary = nil
        @description = nil
        @tags = nil
        @deprecated = nil
        @operation_id = nil
      end

      def resets_request?
        @reset_request
      end

      def resets_response?
        @reset_response
      end

      def introspect
        Apiwork::Introspection.action_definition(self)
      end

      def as_json
        introspect
      end

      def summary(text = nil)
        @summary = text if text
        @summary
      end

      def description(text = nil)
        @description = text if text
        @description
      end

      def tags(*tags_list)
        @tags = tags_list.flatten if tags_list.any?
        @tags
      end

      def deprecated(value = nil)
        @deprecated = value unless value.nil?
        @deprecated
      end

      def operation_id(value = nil)
        @operation_id = value if value
        @operation_id
      end

      def raises(*error_code_keys)
        error_code_keys = error_code_keys.flatten
        error_code_keys.each do |error_code_key|
          unless error_code_key.is_a?(Symbol)
            hint = error_code_key.is_a?(Integer) ? " Use :#{ErrorCode.key_for_status(error_code_key)} instead." : ''
            raise ConfigurationError, "raises must be symbols, got #{error_code_key.class}: #{error_code_key}.#{hint}"
          end

          next if ErrorCode.registered?(error_code_key)

          raise ConfigurationError,
                "Unknown error code :#{error_code_key}. Register it with: " \
                "Apiwork::ErrorCode.register :#{error_code_key}, status: <status>"
        end
        @raises = error_code_keys
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

      def serialize_data(data, context: {}, include: nil)
        needs_serialization = if data.is_a?(Hash)
                                false
                              elsif data.is_a?(Array)
                                data.empty? || data.first.class != Hash
                              else
                                true
                              end

        needs_serialization ? schema_class.serialize(data, context: context, include: include) : data
      end
    end
  end
end
