# frozen_string_literal: true

module Apiwork
  module Controller
    module Concern
      extend ActiveSupport::Concern

      included do
        # Disable Rails parameter wrapping
        # Apiwork contracts define explicit parameter structures
        wrap_parameters false

        rescue_from Apiwork::QueryError do |error|
          render json: { ok: false, errors: error.to_array }, status: :bad_request
        end

        rescue_from Apiwork::ContractError do |error|
          render json: { ok: false, errors: error.to_array }, status: :bad_request
        end

        rescue_from Apiwork::ValidationError do |error|
          render json: { ok: false, errors: error.to_array }, status: :unprocessable_entity
        end
      end

      include Validation
      include Serialization
      include ActionMetadata
    end
  end
end
