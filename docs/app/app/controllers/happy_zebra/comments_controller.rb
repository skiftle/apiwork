# frozen_string_literal: true

module HappyZebra
  class CommentsController < ApplicationController
    def index
      comments = Comment.all
      render_with_contract comments
    end
  end
end
