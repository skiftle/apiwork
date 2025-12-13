# frozen_string_literal: true

module HappyZebra
  class PostsController < ApplicationController
    def index
      posts = Post.all
      respond posts
    end
  end
end
