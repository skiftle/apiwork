# frozen_string_literal: true

module Apiwork
  module Controller
    extend ActiveSupport::Concern

    include Resolution
    include Deserialization
    include Serialization
    include ErrorResponse

    included do
      wrap_parameters false

      rescue_from Apiwork::ConstraintError do |error|
        render_error error.issues, status: error.error_code.status
      end
    end
  end
end
