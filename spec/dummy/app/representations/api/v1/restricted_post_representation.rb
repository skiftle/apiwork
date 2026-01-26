# frozen_string_literal: true

module Api
  module V1
    # RestrictedPostRepresentation - Uses Post model for restricted_posts routes
    # Demonstrates that routing restrictions work with schema inheritance
    class RestrictedPostRepresentation < PostRepresentation
      model Post
    end
  end
end
