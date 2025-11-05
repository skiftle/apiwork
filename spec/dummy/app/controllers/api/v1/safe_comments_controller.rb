# frozen_string_literal: true

module Api
  module V1
    # SafeCommentsController - Demonstrates routing restrictions with except: [:destroy]
    # Inherits from CommentsController to reuse logic
    class SafeCommentsController < CommentsController
      # No code needed - routing DSL handles restrictions
      # All actions except destroy will be accessible
    end
  end
end
