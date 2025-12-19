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

      def introspect(locale: nil)
        Apiwork::Introspection.action_definition(self, locale:)
      end

      def as_json
        introspect
      end

      # Sets a short summary for this action.
      #
      # Used in OpenAPI specs as the operation summary.
      #
      # @param text [String] summary text (optional)
      # @return [String, nil] the summary
      #
      # @example
      #   action :create do
      #     summary 'Create a new invoice'
      #   end
      def summary(text = nil)
        @summary = text if text
        @summary
      end

      # Sets a detailed description for this action.
      #
      # Used in OpenAPI specs as the operation description.
      # Supports Markdown formatting.
      #
      # @param text [String] description text (optional)
      # @return [String, nil] the description
      #
      # @example
      #   action :create do
      #     description 'Creates a new invoice and sends notification email.'
      #   end
      def description(text = nil)
        @description = text if text
        @description
      end

      # Sets OpenAPI tags for grouping this action.
      #
      # Tags help organize actions in generated documentation.
      #
      # @param tags_list [Array<String,Symbol>] tag names
      # @return [Array, nil] the tags
      #
      # @example
      #   action :create do
      #     tags :billing, :invoices
      #   end
      def tags(*tags_list)
        @tags = tags_list.flatten if tags_list.any?
        @tags
      end

      # Marks this action as deprecated.
      #
      # Deprecated actions are flagged in OpenAPI specs.
      #
      # @param value [Boolean] deprecation status (optional)
      # @return [Boolean, nil] whether deprecated
      #
      # @example
      #   action :legacy_create do
      #     deprecated true
      #   end
      def deprecated(value = nil)
        @deprecated = value unless value.nil?
        @deprecated
      end

      # Sets a custom OpenAPI operationId.
      #
      # By default, operationId is auto-generated from resource and action name.
      #
      # @param value [String] custom operation ID (optional)
      # @return [String, nil] the operation ID
      #
      # @example
      #   action :create do
      #     operation_id 'createNewInvoice'
      #   end
      def operation_id(value = nil)
        @operation_id = value if value
        @operation_id
      end

      # Declares error codes this action may return.
      #
      # Error codes must be registered via ErrorCode.register.
      # These appear in OpenAPI specs as possible error responses.
      #
      # @param error_code_keys [Array<Symbol>] error code keys
      # @raise [ConfigurationError] if error code is not registered
      #
      # @example
      #   action :show do
      #     raises :not_found, :forbidden
      #   end
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

      # Defines the request structure for this action.
      #
      # Use the block to define query parameters and request body.
      #
      # @param replace [Boolean] replace inherited definition (default: false)
      # @yield block for defining query and body
      # @return [RequestDefinition] the request definition
      #
      # @example
      #   action :create do
      #     request do
      #       query { param :dry_run, type: :boolean, optional: true }
      #       body { param :title, type: :string }
      #     end
      #   end
      def request(replace: false, &block)
        @reset_request = replace if replace

        @request_definition ||= RequestDefinition.new(contract_class, action_name)

        @request_definition.instance_eval(&block) if block

        @request_definition
      end

      # Defines the response structure for this action.
      #
      # Use the block to define response body or declare no_content.
      #
      # @param replace [Boolean] replace inherited definition (default: false)
      # @yield block for defining body or no_content
      # @return [ResponseDefinition] the response definition
      #
      # @example
      #   action :show do
      #     response do
      #       body { param :id; param :title }
      #     end
      #   end
      #
      # @example No content response
      #   action :destroy do
      #     response { no_content! }
      #   end
      def response(replace: false, &block)
        @reset_response = replace if replace

        @response_definition ||= ResponseDefinition.new(contract_class, action_name)

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
