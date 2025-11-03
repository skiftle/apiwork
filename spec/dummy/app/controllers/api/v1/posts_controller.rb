# frozen_string_literal: true

module Api
  module V1
    class PostsController < V1Controller
      before_action :set_post, only: %i[show update destroy]

      def index
        posts = query(Post.all)
        respond_with posts
      end

      def show
        respond_with post
      end

      def create
        post = Post.create(action_params)
        respond_with post
      end

      def update
        post.update(action_params)
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
end
