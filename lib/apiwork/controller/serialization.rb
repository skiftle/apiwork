# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      included do
        rescue_from Apiwork::ConstraintError do |error|
          render_error error.issues, status: error.error_code.status
        end
      end

      # @api public
      # Renders a successful API response.
      #
      # When a schema is linked via `schema!`, data is serialized through
      # the schema. Otherwise, data is rendered as-is. The adapter applies
      # response transformations (key casing, wrapping, etc.).
      #
      # @param data [Object, Array] the record(s) to render
      # @param meta [Hash] metadata to include in response (pagination, etc.)
      # @param status [Symbol, Integer] HTTP status (default: :ok, or :created for create action)
      #
      # @example Render a single record
      #   def show
      #     invoice = Invoice.find(params[:id])
      #     respond invoice
      #   end
      #
      # @example Render a collection with metadata
      #   def index
      #     invoices = Invoice.all
      #     respond invoices, meta: { total: invoices.count }
      #   end
      #
      # @example Custom status
      #   def create
      #     invoice = Invoice.create!(contract.body)
      #     respond invoice, status: :created
      #   end
      def respond(data, meta: {}, status: nil)
        action_def = contract_class.action_definitions[action_name.to_sym]

        if action_def&.response_definition&.no_content?
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
          result.issues.each(&:warn)
        end

        json = adapter.transform_response(json)
        json = api_class.transform_response(json)
        render json: json, status: status || (action_name.to_sym == :create ? :created : :ok)
      end

      # @api public
      # Renders an error response with validation issues.
      #
      # Use this for validation errors where you have a list of issues.
      # For standard HTTP errors, use `respond_with_error` instead.
      #
      # @param issues [Array<Apiwork::Issue>] list of validation issues
      # @param status [Symbol, Integer] HTTP status (default: :bad_request)
      #
      # @example Render validation errors
      #   def create
      #     unless record.valid?
      #       issues = record.errors.map do |error|
      #         Apiwork::Issue.new(layer: :domain, code: :invalid, detail: error.message, path: [error.attribute], meta: {})
      #       end
      #       render_error issues, status: :unprocessable_entity
      #     end
      #   end
      def render_error(issues, status: :bad_request)
        json = adapter.render_error(issues, build_action_data)
        render json: json, status: status
      end

      # @api public
      # Renders an error response using a registered error code.
      #
      # Error codes are registered via `Apiwork::ErrorCode.register`.
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
      #     return respond_with_error :not_found unless invoice
      #     respond invoice
      #   end
      #
      # @example With custom message
      #   respond_with_error :forbidden, detail: 'You cannot access this invoice'
      #
      # @example With I18n interpolation
      #   respond_with_error :not_found, i18n: { resource: 'Invoice' }
      def respond_with_error(code_key, detail: nil, path: nil, meta: {}, i18n: {})
        error_code = ErrorCode.fetch(code_key)

        issue = Issue.new(
          layer: :http,
          code: error_code.key,
          detail: resolve_error_detail(error_code, detail, i18n),
          path: path || default_error_path(error_code),
          meta:
        )

        render_error [issue], status: error_code.status
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

      def render_with_schema(data, schema_class, meta)
        if data.is_a?(Enumerable)
          adapter.render_collection(data, schema_class, build_action_data(meta))
        else
          adapter.render_record(data, schema_class, build_action_data(meta))
        end
      end

      def build_action_data(meta = {})
        Adapter::ActionData.new(
          action_name,
          request.method_symbol,
          context:,
          query: resource_metadata ? contract.query : {},
          meta:
        )
      end

      def default_error_path(error_code)
        return relative_path.split('/').reject(&:blank?) if error_code.attach_path?

        []
      end

      def resolve_error_detail(error_code, detail, options)
        return detail if detail

        api_path = api_class.metadata&.locale_key
        error_code.description(api_path:, options:)
      end
    end
  end
end
