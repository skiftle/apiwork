# frozen_string_literal: true

module Apiwork
  # Controller for serving spec endpoints
  #
  # Automatically mounted by Routes when API classes use `spec` DSL
  #
  # Supports query parameters for any option defined by the spec generator.
  # Built-in options include:
  # - key_format: Transform key casing (underscore, camel, keep)
  # - locale: Generate spec in specific locale (defaults to I18n.locale)
  #
  # Custom spec options are also supported via query params.
  #
  # @example GET /api/v1/.spec/openapi
  # @example GET /api/v1/.spec/openapi?key_format=underscore
  # @example GET /api/v1/.spec/zod?key_format=camel
  # @example GET /api/v1/.spec/openapi?locale=sv
  # @example GET /api/v1/.spec/my_spec?include_deprecated=true
  class SpecsController < ActionController::API
    # GET /.spec/:type
    #
    # Returns spec for the current API
    def show
      api = find_api
      spec_name = params[:spec_name].to_sym
      spec_config = api.spec_config(spec_name)
      generator_class = ::Apiwork::Spec.find(spec_name)

      options = { key_format: api.key_format }
                .merge(spec_config)
                .merge(generator_class.extract_options(params))
                .compact

      spec = ::Apiwork::Spec.generate(spec_name, api.metadata.path, **options)
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

    def render_spec(spec, content_type)
      if content_type.start_with?('application/json')
        render json: spec
      else
        render plain: spec, content_type: content_type
      end
    end

    def handle_generation_error(error)
      if ::Rails.env.production?

        ::Rails.logger.error("Spec generation failed: #{error.message}")
        ::Rails.logger.error(error.backtrace.join("\n"))
        render json: { error: 'Spec generation failed' }, status: :internal_server_error
      else
        render json: {
          error: error.message,
          backtrace: error.backtrace.take(10)
        }, status: :internal_server_error
      end
    end
  end
end
