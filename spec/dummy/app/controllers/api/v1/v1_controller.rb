# frozen_string_literal: true

module Api
  module V1
    class V1Controller < ApplicationController
      include Apiwork::Controller::Concern

      rescue_from Apiwork::ConstraintErrorCollection do |error|
        render json: { ok: false, errors: error.to_array }, status: :bad_request
      end

      rescue_from Apiwork::ConstraintError, Apiwork::QueryError, Apiwork::SchemaError do |error|
        render json: { ok: false, errors: [error.to_h] }, status: :bad_request
      end

      rescue_from ActiveRecord::RecordNotFound do |error|
        render json: { ok: false, errors: [{ code: 'not_found', detail: error.message }] }, status: :not_found
      end
    end
  end
end
