# frozen_string_literal: true

module Apiwork
  # @api public
  # Mixin for API controllers that provides request validation and response helpers.
  #
  # Include in controllers to access {#contract}, {#expose}, and {#expose_error}.
  # Automatically validates requests against the contract before actions run.
  #
  # @example Basic controller
  #   class InvoicesController < ApplicationController
  #     include Apiwork::Controller
  #
  #     def index
  #       expose Invoice.all
  #     end
  #
  #     def show
  #       invoice = Invoice.find(params[:id])
  #       expose invoice
  #     end
  #
  #     def create
  #       invoice = Invoice.create!(contract.body)
  #       expose invoice, status: :created
  #     end
  #   end
  module Controller
    extend ActiveSupport::Concern

    included do
      wrap_parameters false

      before_action :validate_contract

      rescue_from ConstraintError do |error|
        render_error error
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
        skip_before_action :validate_contract, except:, only:
      end
    end

    # @api public
    # The parsed and validated request contract.
    #
    # The contract contains parsed query parameters and request body,
    # with type coercion applied. Access parameters via {Contract::Base#query}
    # and {Contract::Base#body}.
    #
    # @return [Contract::Base] the contract instance
    # @see Contract::Base
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
      @contract ||= begin
        api_request = Adapter::Request.new(
          body: request.request_parameters,
          query: request.query_parameters,
        ).transform(&:deep_symbolize_keys)
        contract_class.new(action_name, api_request, coerce: true)
      end
    end

    # @api public
    # Exposes data as an API response.
    #
    # When a representation is linked via {Contract::Base.representation}, data is serialized
    # through the representation. Otherwise, data is rendered as-is. The adapter applies
    # response transformations (key casing, wrapping, etc.).
    #
    # @param data [Object, Array] the record(s) to expose
    # @param meta [Hash] metadata to include in response (pagination, etc.)
    # @param status [Symbol, Integer] HTTP status (default: :ok, or :created for create action)
    # @see Representation::Base
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
      if contract_class.actions[action_name.to_sym]&.response&.no_content?
        head :no_content
        return
      end

      representation_class = contract_class.representation_class
      api_request = resource ? contract.request : nil

      json = if representation_class
               action = resource.actions[action_name.to_sym]
               if action.collection?
                 adapter.process_collection(data, representation_class, api_request, context:, meta:)
               else
                 adapter.process_member(data, representation_class, api_request, context:, meta:)
               end
             else
               data[:meta] = meta if meta.present?
               data
             end

      if Rails.env.development?
        result = contract_class.parse_response(json, action_name)
        result.issues.each { |issue| Rails.logger.warn(issue.to_s) }
      end

      response = Adapter::Response.new(body: json)
      response = adapter.transform_response_output(response, api_class: api_class)
      json = response.body

      render json:, status: status || (action_name.to_sym == :create ? :created : :ok)
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
    # @see ErrorCode
    # @see Issue
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
    def expose_error(
      code_key,
      detail: nil,
      path: nil,
      meta: {}
    )
      error_code = ErrorCode.find!(code_key)
      locale_key = api_class.structure.locale_key

      issue = Issue.new(
        error_code.key,
        detail || error_code.description(locale_key:),
        meta:,
        path: path || (error_code.attach_path? ? request.path.delete_prefix(api_class.path).split('/').reject(&:blank?) : []),
      )

      render_error HttpError.new([issue], error_code)
    end

    # @api public
    # The serialization context passed to representations.
    #
    # Override this method to provide context data to your representations.
    # Common uses: current user, permissions, locale, feature flags.
    #
    # @return [Hash] context data available in representation serialization
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

    def render_error(error)
      representation_class = resource ? contract_class.representation_class : nil
      json = adapter.process_error(error, representation_class, context:)
      render json:, status: error.status
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
      @resource ||= api_class.structure.find_resource_for_path(resource_path)
    end

    def resource_path
      @resource_path ||= request.path.delete_prefix(api_class.path).split('/').reject(&:blank?)
    end

    def raise_api_not_found_error
      path = path_parts.empty? ? '/' : "/#{path_parts[0..1].join('/')}"
      api_file = "config/apis/#{path.split('/').reject(&:blank?).join('_')}.rb"

      raise ConfigurationError,
            "No API found for #{self.class.name}. " \
            "Create the API: #{api_file} (Apiwork::API.define '#{path}')"
    end

    def raise_contract_not_found_error
      resource_base = resource.name.to_s.singularize
      namespaces = api_class.structure.namespaces

      contract_name = [*namespaces.map { |namespace| namespace.to_s.camelize }, "#{resource_base.camelize}Contract"].join('::')
      contract_path = ['app/contracts', *namespaces, "#{resource_base}_contract.rb"].join('/')

      raise ConfigurationError,
            "No contract found for #{self.class.name}. " \
            "Create the contract: #{contract_path} (#{contract_name})"
    end

    def find_api_class
      parts = path_parts
      return API.find('/') if parts.empty?

      (parts.length - 1).downto(1) do |index|
        path = "/#{parts[0...index].join('/')}"
        api_class = API.find(path)
        return api_class if api_class
      end

      nil
    end

    def path_parts
      @path_parts ||= request.path.split('/').reject(&:blank?)
    end
  end
end
