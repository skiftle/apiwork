# frozen_string_literal: true

module GentleOwl
  class CommentsController < ApplicationController
    before_action :set_comment, only: %i[show update destroy]

    def index
      comments = Comment.all
      render_with_contract comments
    end

    def show
      render_with_contract comment
    end

    def create
      comment = Comment.create(contract.body[:comment])
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

    private

    attr_reader :comment

    def set_comment
      @comment = Comment.find(params[:id])
    end
  end
end
