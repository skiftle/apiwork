# frozen_string_literal: true

module Api
  module V1
    # SafeCommentSchema - Uses Comment model for safe_comments routes
    # Demonstrates that routing restrictions work with resource inheritance
    class SafeCommentSchema < CommentSchema
      # Inherits all attributes and configuration from CommentSchema
    end
  end
end
