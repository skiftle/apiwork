# frozen_string_literal: true

module Api
  module V1
    class CommentContract < Apiwork::Contract::Base
      schema CommentSchema
    end
  end
end
