# frozen_string_literal: true

module Api
  module V1
    class V1Controller < ApplicationController
      include Apiwork::Controller::Concern

      rescue_from ActiveRecord::RecordNotFound do |error|
        render json: { ok: false, errors: [{ code: 'not_found', detail: error.message }] }, status: :not_found
      end
    end
  end
end
