# frozen_string_literal: true

module Apiwork
  # Controller for serving spec endpoints
  #
  # Automatically mounted by Routes when API classes use `spec` DSL
  #
  # Supports query parameters:
  # - key_format: Transform key casing (underscore, camel, keep)
  # - locale: Generate spec in specific locale (defaults to I18n.locale)
  #
  # @example GET /api/v1/.spec/openapi
  # @example GET /api/v1/.spec/openapi?key_format=underscore
  # @example GET /api/v1/.spec/zod?key_format=camel
  # @example GET /api/v1/.spec/openapi?locale=sv
  class SpecsController < ActionController::API
    # GET /.spec/:type
    #
    # Returns spec for the current API
    def show
      api = find_api
      identifier = params[:spec_type].to_sym
      spec_config = api.spec_config(identifier)

      options = { key_format: api.key_format }
                .merge(spec_config)
                .merge(key_format: params[:key_format]&.to_sym)
                .merge(locale: params[:locale]&.to_sym)
                .compact

      spec = ::Apiwork::Spec.generate(identifier, api.metadata.path, **options)

      generator_class = ::Apiwork::Spec.find(identifier)
      render_spec(spec, generator_class.content_type)
    rescue KeyError => e
      render json: { error: e.message }, status: :bad_request
    rescue ConfigurationError => e
      render json: { error: e.message }, status: :bad_request
    rescue StandardError => e
      handle_generation_error(e)
    end

    private

    def find_api
      api = ::Apiwork::API.find(params[:api_path]) if params[:api_path].present?
      return api if api

      find_api_from_request_path
    end

    def find_api_from_request_path
      path_parts = request.path.split('/').reject(&:blank?)
      return nil if path_parts.empty?

      (path_parts.length - 1).downto(1) do |i|
        path = "/#{path_parts[0...i].join('/')}"
        api = ::Apiwork::API.find(path)
        return api if api
      end

      raise "No API found for path: #{request.path}"
    end

    # Render spec with appropriate content type
    def render_spec(spec, content_type)
      if content_type.start_with?('application/json')
        render json: spec
      else
        render plain: spec, content_type: content_type
      end
    end

    # Handle generation errors
    def handle_generation_error(error)
      if ::Rails.env.production?
        # Log error but don't expose details in production
        ::Rails.logger.error("Spec generation failed: #{error.message}")
        ::Rails.logger.error(error.backtrace.join("\n"))
        render json: { error: 'Spec generation failed' }, status: :internal_server_error
      else
        # Show details in development for debugging
        render json: {
          error: error.message,
          backtrace: error.backtrace.take(10)
        }, status: :internal_server_error
      end
    end
  end
end
