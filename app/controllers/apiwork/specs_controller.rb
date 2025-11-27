# frozen_string_literal: true

module Apiwork
  # Controller for serving spec endpoints
  #
  # Automatically mounted by Routes when API classes use `spec` DSL
  #
  # Supports query parameters:
  # - key_transform: Transform key casing (underscore, camel, keep)
  #
  # @example GET /api/v1/.spec/openapi
  # @example GET /api/v1/.spec/openapi?key_transform=underscore
  # @example GET /api/v1/.spec/zod?key_transform=camel
  class SpecsController < ActionController::API
    # GET /.spec/:type
    #
    # Returns spec for the current API
    def show
      # Use unified Pipeline.generate
      spec = ::Apiwork::Spec::Pipeline.generate(
        api_path: params[:api_path],
        format: params[:spec_type].to_sym,
        key_transform: params[:key_transform]
      )

      # Render with appropriate content type
      generator_class = ::Apiwork::Spec::Registry.find(params[:spec_type].to_sym)
      render_spec(spec, generator_class.content_type)
    rescue KeyError => e
      render json: { error: e.message }, status: :bad_request
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue StandardError => e
      handle_generation_error(e)
    end

    private

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
