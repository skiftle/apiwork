# frozen_string_literal: true

module Api
  module V1
    class RestrictedPostContract < Apiwork::Contract::Base
      schema RestrictedPostSchema

      # Restricted posts - uses same schema as posts but with restricted access
      # No custom actions needed
    end
  end
end
