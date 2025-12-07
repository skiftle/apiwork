# frozen_string_literal: true

module GentleOwl
  class CommentsController < ApplicationController
    before_action :set_comment, only: %i[show update destroy]

    def index
      comments = Comment.all
      respond_with comments
    end

    def show
      respond_with comment
    end

    def create
      comment = Comment.create(contract.body[:comment])
      respond_with comment
    end

    def update
      comment.update(contract.body[:comment])
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
