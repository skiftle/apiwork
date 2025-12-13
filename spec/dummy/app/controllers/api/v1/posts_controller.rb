# frozen_string_literal: true

module Api
  module V1
    class PostsController < V1Controller
      before_action :set_post, only: %i[show update destroy publish archive preview]

      def index
        render_with_contract Post.all
      end

      def show
        render_with_contract post
      end

      def create
        post = Post.create(contract.body[:post])
        render_with_contract post
      end

      def update
        post.update(contract.body[:post])
        render_with_contract post
      end

      def destroy
        post.destroy
        render_with_contract post
      end

      # Member actions
      def publish
        post.update(published: true)
        render_with_contract post
      end

      def archive
        post.update(published: false)
        render_with_contract post
      end

      def preview
        # Return post object - render_with_contract will serialize it
        render_with_contract post
      end

      # Collection actions
      def search
        query_string = contract.query[:q]
        posts = if query_string.present?
          Post.where('title LIKE ? OR body LIKE ?', "%#{query_string}%", "%#{query_string}%")
        else
          Post.all
        end
        render_with_contract posts
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
        render_with_contract posts, status: :created
      end

      private

      attr_reader :post

      def set_post
        @post = Post.find(params[:id])
      end
    end
  end
end
