# frozen_string_literal: true

module Apiwork
  # @api public
  module Controller
    extend ActiveSupport::Concern

    included do
      wrap_parameters false
      before_action :validate_contract

      rescue_from ContractError, DomainError do |error|
        render_error error.layer, error.issues, error.status
      end
    end

    # @!method self.skip_contract_validation!(only: nil, except: nil)
    #   @api public
    #   Skips contract validation for specified actions.
    #
    #   @param only [Array<Symbol>] skip only for these
    #   @param except [Array<Symbol>] skip for all except these
    #
    #   @example Skip for specific actions
    #     skip_contract_validation! only: [:ping, :status]
    #
    #   @example Skip for all actions
    #     skip_contract_validation!
    class_methods do
      def skip_contract_validation!(except: nil, only: nil)
        skip_before_action :validate_contract, only:, except:
      end
    end

    # @api public
    # Returns the parsed and validated request contract.
    #
    # The contract contains parsed query parameters and request body,
    # with type coercion applied. Access parameters via {Contract::Base#query}
    # and {Contract::Base#body}.
    #
    # @return [Contract::Base] the contract instance
    #
    # @example Access parsed parameters
    #   def create
    #     invoice = Invoice.new(contract.body)
    #     # contract.body contains validated, coerced params
    #   end
    #
    # @example Check for specific parameters
    #   def index
    #     if contract.query[:include]
    #       # handle include parameter
    #     end
    #   end
    def contract
      @contract ||= contract_class.new(
        query: transformed_query_parameters,
        body: transformed_body_parameters,
        action_name: action_name,
        coerce: true
      )
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
               if data.is_a?(Enumerable)
                 adapter.render_collection(data, schema_class, build_action_summary(meta))
               else
                 adapter.render_record(data, schema_class, build_action_summary(meta))
               end
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
    def expose_error(code_key,
                     detail: nil,
                     path: nil,
                     meta: {},
                     i18n: {})
      error_code = ErrorCode.fetch(code_key)
      locale_key = api_class.structure.locale_key

      issue = Issue.new(
        code: error_code.key,
        detail: detail || error_code.description(locale_key:, options: i18n),
        path: path || (error_code.attach_path? ? request.path.delete_prefix(api_class.path).split('/').reject(&:blank?) : []),
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

    def validate_contract
      return unless resource
      return if contract.valid?

      raise ContractError, contract.issues
    end

    def render_error(layer, issues, status)
      json = adapter.render_error(layer, issues, build_action_summary)
      render json: json, status: status
    end

    def build_action_summary(meta = {})
      Adapter::ActionSummary.new(
        action_name,
        request.method_symbol,
        type: resource&.actions&.dig(action_name.to_sym)&.type,
        context:,
        query: resource ? contract.query : {},
        meta:
      )
    end

    def transformed_query_parameters
      parameters = request.query_parameters.deep_symbolize_keys
      parameters = api_class.transform_request(parameters)
      adapter.transform_request(parameters)
    end

    def transformed_body_parameters
      parameters = request.request_parameters.deep_symbolize_keys
      parameters = api_class.transform_request(parameters)
      adapter.transform_request(parameters)
    end

    def contract_class
      @contract_class ||= begin
        klass = resource&.resolve_contract_class
        klass || raise_contract_not_found_error
      end
    end

    def api_class
      @api_class ||= find_api_class || raise_api_not_found_error
    end

    def adapter
      api_class.adapter
    end

    def resource
      @resource ||= api_class.structure.find_resource(resource_name)
    end

    def raise_api_not_found_error
      path = path_parts.empty? ? '/' : "/#{path_parts[0..1].join('/')}"
      api_file = "config/apis/#{path.split('/').reject(&:blank?).join('_')}.rb"

      raise ConfigurationError,
            "No API found for #{self.class.name}. " \
            "Create the API: #{api_file} (Apiwork::API.define '#{path}')"
    end

    def raise_contract_not_found_error
      resource_base = resource_name.to_s.singularize
      namespaces = api_class.structure.namespaces

      contract_name = [*namespaces.map { |n| n.to_s.camelize }, "#{resource_base.camelize}Contract"].join('::')
      contract_path = ['app/contracts', *namespaces, "#{resource_base}_contract.rb"].join('/')

      raise ConfigurationError,
            "No contract found for #{self.class.name}. " \
            "Create the contract: #{contract_path} (#{contract_name})"
    end

    def find_api_class
      parts = path_parts
      return API.find('/') if parts.empty?

      (parts.length - 1).downto(1) do |i|
        path = "/#{parts[0...i].join('/')}"
        api_class = API.find(path)
        return api_class if api_class
      end

      nil
    end

    def resource_name
      @resource_name ||= begin
        base_name = self.class.name.underscore.delete_suffix('_controller').split('/').last

        plural = base_name.to_sym
        singular = base_name.singularize.to_sym

        api_class.structure.find_resource(plural) ? plural : singular
      end
    end

    def path_parts
      @path_parts ||= request.path.split('/').reject(&:blank?)
    end
  end
end
