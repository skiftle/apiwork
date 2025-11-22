# frozen_string_literal: true

module Api
  module V1
    # ArticlesController - Alternative controller for Post model
    # Demonstrates resource override: same model, different serialization
    #
    # Uses ArticleResource which only exposes id and title,
    # while PostsController uses PostResource which exposes all fields.
    class ArticlesController < V1Controller

      def index
        respond_with Post.all
      end

      def show
        article = Post.find(params[:id])
        respond_with article
      end

      def create
        article = Post.new(action_request[:article])
        # Create full Post model but only expose id + title in response
        article.body = "Auto-generated body"
        article.published = false
        article.save
        respond_with article
      end

      def update
        article = Post.find(params[:id])
        article.update(action_request[:article])
        respond_with article
      end

      def destroy
        article = Post.find(params[:id])
        article.destroy
        respond_with article
      end
    end
  end
end
