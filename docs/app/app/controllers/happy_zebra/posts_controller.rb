# frozen_string_literal: true

module HappyZebra
  class PostsController < ApplicationController
    def index
      posts = Post.all
      respond_with posts
    end
  end
end
