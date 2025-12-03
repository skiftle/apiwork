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
        @error_codes = []
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

      def error_codes(*codes)
        codes = codes.flatten
        codes.each do |code|
          unless code.is_a?(Symbol)
            hint = code.is_a?(Integer) ? " Use :#{ErrorCode.name_for_status(code)} instead." : ''
            raise ConfigurationError, "error_codes must be symbols, got #{code.class}: #{code}.#{hint}"
          end

          next if ErrorCode.registered?(code)

          raise ConfigurationError,
                "Unknown error code :#{code}. Register it with: " \
                "Apiwork::ErrorCode.register :#{code}, status: <status>"
        end
        @error_codes = codes
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
