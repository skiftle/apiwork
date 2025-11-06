# frozen_string_literal: true

module Api
  module V1
    # SafeCommentContract - Contract for SafeCommentSchema
    # Uses auto-generation with default behavior
    class SafeCommentContract < Apiwork::Contract::Base
      schema SafeCommentSchema

      # Auto-generation will handle create/update actions
    end
  end
end
