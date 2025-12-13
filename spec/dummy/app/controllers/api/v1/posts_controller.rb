# frozen_string_literal: true

module Api
  module V1
    class PostsController < V1Controller
      before_action :set_post, only: %i[show update destroy publish archive preview]

      def index
        respond Post.all
      end

      def show
        respond post
      end

      def create
        post = Post.create(contract.body[:post])
        respond post
      end

      def update
        post.update(contract.body[:post])
        respond post
      end

      def destroy
        post.destroy
        respond post
      end

      # Member actions
      def publish
        post.update(published: true)
        respond post
      end

      def archive
        post.update(published: false)
        respond post
      end

      def preview
        # Return post object - respond will serialize it
        respond post
      end

      # Collection actions
      def search
        query_string = contract.query[:q]
        posts = if query_string.present?
          Post.where('title LIKE ? OR body LIKE ?', "%#{query_string}%", "%#{query_string}%")
        else
          Post.all
        end
        respond posts
      end

      def bulk_create
        posts_params = contract.body[:posts] || []
        created_ids = posts_params.map do |post_params|
          post = Post.create(
            title: post_params[:title],
            body: post_params[:body],
            published: post_params[:published] || false
          )
          post.id
        end
        posts = Post.where(id: created_ids)
        respond posts, status: :created
      end

      private

      attr_reader :post

      def set_post
        @post = Post.find(params[:id])
      end
    end
  end
end
