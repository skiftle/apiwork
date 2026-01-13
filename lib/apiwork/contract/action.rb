# frozen_string_literal: true

module Apiwork
  module Contract
    # Defines request/response structure for an action.
    #
    # Returns {Request} via `request` and {Response} via `response`.
    #
    # @api public
    class Action
      attr_reader :contract_class,
                  :name

      def initialize(contract_class, name, replace: false)
        @name = name
        @contract_class = contract_class
        @reset_request = replace
        @reset_response = replace
        @request = nil
        @response = nil
        @raises = []
        @summary = nil
        @description = nil
        @tags = nil
        @deprecated = nil
        @operation_id = nil
      end

      # @api public
      # Sets a short summary for this action.
      #
      # Used in generated specs as the operation summary.
      #
      # @param value [String] summary text (optional)
      # @return [String, nil] the summary
      #
      # @example
      #   action :create do
      #     summary 'Create a new invoice'
      #   end
      def summary(value = nil)
        @summary = value if value
        @summary
      end

      # @api public
      # Sets a detailed description for this action.
      #
      # Used in generated specs as the operation description.
      # Supports Markdown formatting.
      #
      # @param value [String] description text (optional)
      # @return [String, nil] the description
      #
      # @example
      #   action :create do
      #     description 'Creates a new invoice and sends notification email.'
      #   end
      def description(value = nil)
        @description = value if value
        @description
      end

      # @api public
      # Sets tags for grouping this action.
      #
      # Tags help organize actions in generated documentation.
      #
      # @param tags [Array<String,Symbol>] tag names
      # @return [Array, nil] the tags
      #
      # @example
      #   action :create do
      #     tags :billing, :invoices
      #   end
      def tags(*tags)
        @tags = tags.flatten if tags.any?
        @tags
      end

      # @api public
      # Marks this action as deprecated.
      #
      # Deprecated actions are flagged in generated specs.
      #
      # @return [void]
      #
      # @example
      #   action :legacy_create do
      #     deprecated!
      #   end
      def deprecated!
        @deprecated = true
      end

      # @api public
      # Sets a custom operation ID.
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

      # @api public
      # Declares error codes this action may return.
      #
      # Uses built-in error codes (:not_found, :forbidden, etc.) or custom codes
      # registered via ErrorCode.register. These appear in generated specs.
      #
      # Multiple calls merge error codes (consistent with declaration merging).
      #
      # @param error_code_keys [Array<Symbol>] error code keys
      # @raise [ConfigurationError] if error code is not registered
      # @see ErrorCode
      #
      # @example Merging error codes
      #   raises :not_found
      #   raises :forbidden
      #   # Result: [:not_found, :forbidden]
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
        @raises |= error_code_keys
      end

      # @api public
      # Defines the request structure for this action.
      #
      # Use the block to define query parameters and request body.
      #
      # @param replace [Boolean] replace inherited definition (default: false)
      # @yield block for defining query and body
      # @return [Request] the request definition
      # @see Contract::Request
      #
      # @example
      #   action :create do
      #     request do
      #       query do
      #         boolean :dry_run, optional: true
      #       end
      #       body do
      #         string :title
      #       end
      #     end
      #   end
      def request(replace: false, &block)
        @reset_request = replace if replace

        @request ||= Request.new(contract_class, name)

        @request.instance_eval(&block) if block

        @request
      end

      # @api public
      # Defines the response structure for this action.
      #
      # Use the block to define response body or declare no_content.
      #
      # @param replace [Boolean] replace inherited definition (default: false)
      # @yield block for defining body or no_content
      # @return [Response] the response definition
      # @see Contract::Response
      #
      # @example
      #   action :show do
      #     response do
      #       body do
      #         uuid :id
      #         string :title
      #       end
      #     end
      #   end
      #
      # @example No content response
      #   action :destroy do
      #     response do
      #       no_content!
      #     end
      #   end
      def response(replace: false, &block)
        @reset_response = replace if replace

        @response ||= Response.new(contract_class, name)

        @response.instance_eval(&block) if block

        @response
      end

      def resets_request?
        @reset_request
      end

      def resets_response?
        @reset_response
      end

      def deprecated?
        @deprecated == true
      end
    end
  end
end
