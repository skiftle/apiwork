# frozen_string_literal: true

module Api
  module V1
    class RestrictedPostsContract < Apiwork::Contract::Base
      schema 'Api::V1::RestrictedPostSchema'

      # Restricted posts - uses same schema as posts but with restricted access
      # No custom actions needed
    end
  end
end
