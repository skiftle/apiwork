# frozen_string_literal: true

module Api
  module V1
    # SafeCommentResource - Uses Comment model for safe_comments routes
    # Demonstrates that routing restrictions work with resource inheritance
    class SafeCommentResource < CommentResource
      # Inherits all attributes and configuration from CommentResource
    end
  end
end
