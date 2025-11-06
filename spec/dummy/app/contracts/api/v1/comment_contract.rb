# frozen_string_literal: true

module Api
  module V1
    class CommentContract < Apiwork::Contract::Base
      schema CommentSchema

      # Standard CRUD actions use auto-generated input/output from schema
      # No custom actions needed for comments
    end
  end
end
