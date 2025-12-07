# frozen_string_literal: true

module Api
  module V1
    # RestrictedPostSchema - Uses Post model for restricted_posts routes
    # Demonstrates that routing restrictions work with schema inheritance
    class RestrictedPostSchema < PostSchema
      model Post
    end
  end
end
