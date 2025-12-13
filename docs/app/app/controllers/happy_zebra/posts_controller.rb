# frozen_string_literal: true

module HappyZebra
  class PostsController < ApplicationController
    def index
      posts = Post.all
      render_with_contract posts
    end
  end
end
