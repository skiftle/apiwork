# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      included do
        rescue_from ContractError, DomainError do |error|
          render_error error.layer, error.issues, error.status
        end
      end

      # @api public
      # Exposes data as an API response.
      #
      # When a schema is linked via {Contract::Base.schema!}, data is serialized
      # through the schema. Otherwise, data is rendered as-is. The adapter applies
      # response transformations (key casing, wrapping, etc.).
      #
      # @param data [Object, Array] the record(s) to expose
      # @param meta [Hash] metadata to include in response (pagination, etc.)
      # @param status [Symbol, Integer] HTTP status (default: :ok, or :created for create action)
      #
      # @example Expose a single record
      #   def show
      #     invoice = Invoice.find(params[:id])
      #     expose invoice
      #   end
      #
      # @example Expose a collection with metadata
      #   def index
      #     invoices = Invoice.all
      #     expose invoices, meta: { total: invoices.count }
      #   end
      #
      # @example Custom status
      #   def create
      #     invoice = Invoice.create!(contract.body)
      #     expose invoice, status: :created
      #   end
      def expose(data, meta: {}, status: nil)
        action_definition = contract_class.action_definitions[action_name.to_sym]

        if action_definition&.response_definition&.no_content?
          head :no_content
          return
        end

        schema_class = contract_class.schema_class

        json = if schema_class
                 render_with_schema(data, schema_class, meta)
               else
                 data[:meta] = meta if meta.present?
                 data
               end

        if Rails.env.development?
          result = contract_class.parse_response(json, action_name)
          result.issues.each { |issue| Rails.logger.warn(issue.to_s) }
        end

        json = adapter.transform_response(json, schema_class)
        json = api_class.transform_response(json)
        render json: json, status: status || (action_name.to_sym == :create ? :created : :ok)
      end

      # @api public
      # Exposes an error response using a registered error code.
      #
      # Error codes are registered via {ErrorCode.register}.
      # The detail message is looked up from I18n if not provided.
      #
      # @param code_key [Symbol] registered error code (:not_found, :unauthorized, etc.)
      # @param detail [String] custom error message (optional, uses I18n lookup)
      # @param path [Array<String,Symbol>] JSON path to the error (optional)
      # @param meta [Hash] additional metadata to include (optional)
      # @param i18n [Hash] interpolation values for I18n lookup (optional)
      #
      # @example Not found error
      #   def show
      #     invoice = Invoice.find_by(id: params[:id])
      #     return expose_error :not_found unless invoice
      #     expose invoice
      #   end
      #
      # @example With custom message
      #   expose_error :forbidden, detail: 'You cannot access this invoice'
      #
      # @example With I18n interpolation
      #   expose_error :not_found, i18n: { resource: 'Invoice' }
      def expose_error(code_key, detail: nil, path: nil, meta: {}, i18n: {})
        error_code = ErrorCode.fetch(code_key)

        issue = Issue.new(
          code: error_code.key,
          detail: resolve_error_detail(error_code, detail, i18n),
          path: path || default_error_path(error_code),
          meta:
        )

        render_error :http, [issue], error_code.status
      end

      # @api public
      # Returns the serialization context passed to schemas.
      #
      # Override this method to provide context data to your schemas.
      # Common uses: current user, permissions, locale, feature flags.
      #
      # @return [Hash] context data available in schema serialization
      #
      # @example Provide current user context
      #   def context
      #     { current_user: current_user }
      #   end
      def context
        {}
      end

      private

      def render_error(layer, issues, status)
        json = adapter.render_error(layer, issues, build_action_summary)
        render json: json, status: status
      end

      def render_with_schema(data, schema_class, meta)
        if data.is_a?(Enumerable)
          adapter.render_collection(data, schema_class, build_action_summary(meta))
        else
          adapter.render_record(data, schema_class, build_action_summary(meta))
        end
      end

      def build_action_summary(meta = {})
        Adapter::ActionSummary.new(
          action_name,
          request.method_symbol,
          type: action_type,
          context:,
          query: resource_metadata ? contract.query : {},
          meta:
        )
      end

      def action_type
        return nil unless resource_metadata

        action = resource_metadata.actions[action_name.to_sym]
        action&.type
      end

      def default_error_path(error_code)
        return relative_path.split('/').reject(&:blank?) if error_code.attach_path?

        []
      end

      def resolve_error_detail(error_code, detail, options)
        return detail if detail

        locale_key = api_class.structure&.locale_key
        error_code.description(locale_key:, options:)
      end
    end
  end
end
