# frozen_string_literal: true

module Api
  module V1
    class CommentsController < V1Controller
      before_action :set_comment, only: %i[show update destroy]

      def index
        comments = query(Comment.all)
        respond_with comments
      end

      def show
        respond_with comment
      end

      def create
        comment = Comment.create(action_params)
        respond_with comment
      end

      def update
        comment.update(action_params)
        respond_with comment
      end

      def destroy
        comment.destroy
        respond_with comment
      end

      private

      attr_reader :comment

      def set_comment
        @comment = Comment.find(params[:id])
      end
    end
  end
end
