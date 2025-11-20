# frozen_string_literal: true

module Api
  module V1
    class RestrictedPostContract < Apiwork::Contract::Base
      schema Api::V1::RestrictedPostSchema
    end
  end
end
