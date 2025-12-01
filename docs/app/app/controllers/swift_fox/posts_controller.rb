# frozen_string_literal: true

module SwiftFox
  class PostsController < ApplicationController
    include Apiwork::Controller::Concern

    before_action :set_post, only: %i[show update destroy]

    def index
      posts = Post.all
      respond_with posts
    end

    def show
      respond_with post
    end

    def create
      post = Post.create(contract.body[:post])
      respond_with post
    end

    def update
      post.update(contract.body[:post])
      respond_with post
    end

    def destroy
      post.destroy
      respond_with post
    end

    private

    attr_reader :post

    def set_post
      @post = Post.find(params[:id])
    end
  end
end
