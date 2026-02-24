# frozen_string_literal: true

module HappyZebra
  class CommentsController < ApplicationController
    def index
      comments = Comment.all
      expose comments
    end
  end
end
