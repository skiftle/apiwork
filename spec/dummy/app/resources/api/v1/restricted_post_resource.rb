# frozen_string_literal: true

module Api
  module V1
    # RestrictedPostResource - Uses Post model for restricted_posts routes
    # Demonstrates that routing restrictions work with resource inheritance
    class RestrictedPostResource < PostResource
      # Inherits all attributes and configuration from PostResource
    end
  end
end
