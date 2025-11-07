# frozen_string_literal: true

module Api
  module V1
    class PostsController < V1Controller
      before_action :set_post, only: %i[show update destroy publish archive preview]

      def index
        respond_with Post.all
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

      # Member actions
      def publish
        post.update(published: true)
        respond_with post
      end

      def archive
        post.update(published: false)
        respond_with post
      end

      def preview
        # Return post object - respond_with will serialize it
        respond_with post
      end

      # Collection actions
      def search
        query_string = action_params[:q]
        posts = if query_string.present?
          Post.where('title LIKE ? OR body LIKE ?', "%#{query_string}%", "%#{query_string}%")
        else
          Post.all
        end
        respond_with posts
      end

      def bulk_create
        posts_params = action_params[:posts] || []
        created_ids = posts_params.map do |post_params|
          post = Post.create(
            title: post_params[:title],
            body: post_params[:body],
            published: post_params[:published] || false
          )
          post.id
        end
        posts = Post.where(id: created_ids)
        respond_with posts
      end

      private

      attr_reader :post

      def set_post
        @post = Post.find(params[:id])
      end
    end
  end
end
