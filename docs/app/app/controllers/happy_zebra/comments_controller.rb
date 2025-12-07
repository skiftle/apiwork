# frozen_string_literal: true

module HappyZebra
  class CommentsController < ApplicationController
    def index
      comments = Comment.all
      respond_with comments
    end
  end
end
