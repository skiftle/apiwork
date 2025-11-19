# frozen_string_literal: true

module Apiwork
  module Controller
    module Concern
      extend ActiveSupport::Concern

      include ContractResolution
      include Deserialization
      include Serialization

      included do
        # Disable Rails parameter wrapping
        # Apiwork contracts define explicit parameter structures
        wrap_parameters false

        rescue_from Apiwork::ConstraintError do |error|
          render json: { ok: false, issues: error.issues }, status: error.http_status
        end
      end
    end
  end
end
