# frozen_string_literal: true

module Api
  module V1
    class CommentsController < V1Controller
      before_action :set_comment, only: %i[show update destroy approve]

      def index
        # Support both nested and non-nested routes
        comments = if params[:post_id]
          Comment.where(post_id: params[:post_id])
        else
          Comment.all
        end
        render_with_contract comments
      end

      def show
        render_with_contract comment
      end

      def create
        # Merge post_id from route params if present (nested route)
        params_with_post = if params[:post_id]
          contract.body[:comment].merge(post_id: params[:post_id])
        else
          contract.body[:comment]
        end
        comment = Comment.create(params_with_post)
        render_with_contract comment
      end

      def update
        comment.update(contract.body[:comment])
        render_with_contract comment
      end

      def destroy
        comment.destroy
        render_with_contract comment
      end

      # Member action for nested resources
      def approve
        # Dummy implementation - just return the comment
        render_with_contract comment
      end

      # Collection action for nested resources
      def recent
        # Get recent comments, optionally scoped to a post
        comments = if params[:post_id]
          Comment.where(post_id: params[:post_id]).order(created_at: :desc).limit(5)
        else
          Comment.order(created_at: :desc).limit(5)
        end
        render_with_contract comments
      end

      private

      attr_reader :comment

      def set_comment
        # Support both nested and non-nested routes
        @comment = if params[:post_id]
          Comment.where(post_id: params[:post_id]).find(params[:id])
        else
          Comment.find(params[:id])
        end
      end
    end
  end
end
