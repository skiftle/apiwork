# frozen_string_literal: true

module Api
  module V1
    class CommentContract < Apiwork::Contract::Base
      representation CommentRepresentation
    end
  end
end
