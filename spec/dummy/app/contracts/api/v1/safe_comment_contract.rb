# frozen_string_literal: true

module Api
  module V1
    # SafeCommentContract - Contract for SafeCommentResource
    # Uses auto-generation with default behavior
    class SafeCommentContract < Apiwork::Contract::Base
      resource Api::V1::SafeCommentResource

      # Auto-generation will handle create/update actions
    end
  end
end
