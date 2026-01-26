# frozen_string_literal: true

module Api
  module V1
    class RestrictedPostContract < Apiwork::Contract::Base
      representation RestrictedPostRepresentation
    end
  end
end
