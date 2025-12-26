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
        expose Post.all
      end

      def show
        article = Post.find(params[:id])
        expose article
      end

      def create
        article = Post.new(contract.body[:article])
        # Create full Post model but only expose id + title in response
        article.body = "Auto-generated body"
        article.published = false
        article.save
        expose article
      end

      def update
        article = Post.find(params[:id])
        article.update(contract.body[:article])
        expose article
      end

      def destroy
        article = Post.find(params[:id])
        article.destroy
        expose article
      end
    end
  end
end
