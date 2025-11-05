# frozen_string_literal: true

module Api
  module V1
    # RestrictedPostsController - Demonstrates routing restrictions with only: [:index, :show]
    # Inherits from PostsController to reuse logic
    class RestrictedPostsController < PostsController
      # No code needed - routing DSL handles restrictions
      # Only index and show actions will be accessible
    end
  end
end
