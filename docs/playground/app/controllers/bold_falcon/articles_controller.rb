# frozen_string_literal: true

module BoldFalcon
  class ArticlesController < ApplicationController
    before_action :set_article, only: %i[show update destroy]

    def index
      articles = Article.all
      respond articles
    end

    def show
      respond article
    end

    def create
      article = Article.create(contract.body[:article])
      respond article
    end

    def update
      article.update(contract.body[:article])
      respond article
    end

    def destroy
      article.destroy
      respond article
    end

    private

    attr_reader :article

    def set_article
      @article = Article.find(params[:id])
    end
  end
end
