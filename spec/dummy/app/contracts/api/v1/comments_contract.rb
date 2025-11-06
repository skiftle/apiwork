# frozen_string_literal: true

module Api
  module V1
    class CommentsContract < Apiwork::Contract::Base
      schema 'Api::V1::CommentSchema'

      # Standard CRUD actions use auto-generated input/output from schema
      # No custom actions needed for comments
    end
  end
end
