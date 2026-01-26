# frozen_string_literal: true

module Api
  module V1
    # SafeCommentRepresentation - Uses Comment model for safe_comments routes
    # Demonstrates that routing restrictions work with resource inheritance
    class SafeCommentRepresentation < CommentRepresentation
      model Comment
    end
  end
end
