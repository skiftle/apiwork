# frozen_string_literal: true

module Apiwork
  module Controller
    module Concern
      extend ActiveSupport::Concern

      included do
        # Disable Rails parameter wrapping
        # Apiwork contracts define explicit parameter structures
        wrap_parameters false
      end

      include Validation
      include Serialization
      include ActionMetadata
    end
  end
end
