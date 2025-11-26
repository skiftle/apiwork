# frozen_string_literal: true

module Apiwork
  module Controller
    module Concern
      extend ActiveSupport::Concern

      include ContractResolution
      include Deserialization
      include Serialization

      included do
        wrap_parameters false

        rescue_from Apiwork::ConstraintError do |error|
          render_error error.issues, status: error.http_status
        end
      end
    end
  end
end
