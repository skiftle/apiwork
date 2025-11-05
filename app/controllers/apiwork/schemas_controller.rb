# frozen_string_literal: true

module Apiwork
  # Controller for serving schema endpoints
  #
  # Automatically mounted by Routes when API classes use `schemas` DSL
  #
  # Supports query parameters:
  # - key_transform: Transform key casing (underscore, camelize_lower, etc.)
  # - builders: Include builder functions (for Transport generator)
  #
  # @example GET /api/v1/.schema/openapi
  # @example GET /api/v1/.schema/openapi?key_transform=underscore
  # @example GET /api/v1/.schema/transport?builders=true&key_transform=camelize_lower
  class SchemasController < ActionController::API
    # GET /.schema/:type
    #
    # Returns schema for the current API
    def show
      # Use unified Schema.generate
      schema = ::Apiwork::Generation::Schema.generate(
        api_path: params[:api_path],
        format: params[:schema_type].to_sym,
        key_transform: params[:key_transform],
        builders: params[:builders]
      )

      # Render with appropriate content type
      generator_class = ::Apiwork::Generation::Registry[params[:schema_type].to_sym]
      render_schema(schema, generator_class.content_type)
    rescue ::Apiwork::Generation::Registry::GeneratorNotFound => e
      render json: { error: e.message }, status: :bad_request
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue StandardError => e
      handle_generation_error(e)
    end

    private

    # Render schema with appropriate content type
    def render_schema(schema, content_type)
      if content_type.start_with?('application/json')
        render json: schema
      else
        render plain: schema, content_type: content_type
      end
    end

    # Handle generation errors
    def handle_generation_error(error)
      if ::Rails.env.production?
        # Log error but don't expose details in production
        ::Rails.logger.error("Schema generation failed: #{error.message}")
        ::Rails.logger.error(error.backtrace.join("\n"))
        render json: { error: 'Schema generation failed' }, status: :internal_server_error
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
