# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Defines request/response structure for an action.
    #
    # Returns {Action::Request} via `request` and {Action::Response} via `response`.
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
      # The summary for this action.
      #
      # Used in generated specs as the operation summary.
      #
      # @param value [String, nil] (nil)
      #   The summary.
      # @return [String, nil]
      #
      # @example
      #   action :create do
      #     summary 'Create a new invoice'
      #   end
      def summary(value = nil)
        return @summary if value.nil?

        @summary = value
      end

      # @api public
      # The description for this action.
      #
      # Used in generated specs as the operation description.
      # Supports Markdown formatting.
      #
      # @param value [String, nil] (nil)
      #   The description.
      # @return [String, nil]
      #
      # @example
      #   action :create do
      #     description 'Creates a new invoice and sends notification email.'
      #   end
      def description(value = nil)
        return @description if value.nil?

        @description = value
      end

      # @api public
      # The tags for this action.
      #
      # Tags help organize actions in generated documentation.
      #
      # @param tags [Array<String, Symbol>]
      #   The tag names.
      # @return [Array<Symbol>, nil]
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
      # Whether this action is deprecated.
      #
      # @return [Boolean]
      def deprecated?
        @deprecated == true
      end

      # @api public
      # The operation ID for this action.
      #
      # @param value [String, nil] (nil)
      #   The operation ID.
      # @return [String, nil]
      #
      # @example
      #   action :create do
      #     operation_id 'createNewInvoice'
      #   end
      def operation_id(value = nil)
        return @operation_id if value.nil?

        @operation_id = value
      end

      # @api public
      # Declares the raised error codes for this action.
      #
      # @param error_code_keys [Symbol]
      #   The error code keys.
      # @return [void]
      # @raise [ConfigurationError] if error code is not registered
      #
      # @example
      #   raises :not_found
      #   raises :forbidden
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

          next if ErrorCode.exists?(error_code_key)

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
      # @param replace [Boolean] (false)
      #   Whether to replace inherited definition.
      # @yield block for defining query and body (instance_eval style)
      # @yieldparam request [Action::Request]
      # @return [Action::Request]
      #
      # @example instance_eval style
      #   action :create do
      #     request do
      #       query do
      #         boolean? :dry_run
      #       end
      #       body do
      #         string :title
      #       end
      #     end
      #   end
      #
      # @example yield style
      #   action :create do
      #     request do |request|
      #       request.query do |query|
      #         query.boolean? :dry_run
      #       end
      #       request.body do |body|
      #         body.string :title
      #       end
      #     end
      #   end
      def request(replace: false, &block)
        @reset_request = replace if replace

        @request ||= Request.new(contract_class, name)

        if block
          block.arity.positive? ? yield(@request) : @request.instance_eval(&block)
        end

        @request
      end

      # @api public
      # Defines the response structure for this action.
      #
      # Use the block to define response body or declare no_content.
      #
      # @param replace [Boolean] (false)
      #   Whether to replace inherited definition.
      # @yield block for defining body or no_content (instance_eval style)
      # @yieldparam response [Action::Response]
      # @return [Action::Response]
      #
      # @example instance_eval style
      #   action :show do
      #     response do
      #       body do
      #         uuid :id
      #         string :title
      #       end
      #     end
      #   end
      #
      # @example yield style
      #   action :show do
      #     response do |response|
      #       response.body do |body|
      #         body.uuid :id
      #         body.string :title
      #       end
      #     end
      #   end
      #
      # @example No content response
      #   action :destroy do
      #     response { no_content! }
      #   end
      def response(replace: false, &block)
        @reset_response = replace if replace

        @response ||= Response.new(contract_class, name)

        if block
          block.arity.positive? ? yield(@response) : @response.instance_eval(&block)
        end

        @response
      end

      def resets_request?
        @reset_request
      end

      def resets_response?
        @reset_response
      end
    end
  end
end
