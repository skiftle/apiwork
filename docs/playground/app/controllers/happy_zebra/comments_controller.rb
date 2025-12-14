# frozen_string_literal: true

module HappyZebra
  class CommentsController < ApplicationController
    def index
      comments = Comment.all
      respond comments
    end
  end
end
