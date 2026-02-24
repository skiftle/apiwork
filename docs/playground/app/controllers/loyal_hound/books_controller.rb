# frozen_string_literal: true

module LoyalHound
  class BooksController < ApplicationController
    before_action :set_book, only: %i[show update destroy]

    def index
      books = Book.all
      expose books
    end

    def show
      expose book
    end

    def create
      book = Book.create(contract.body[:book])
      expose book
    end

    def update
      book.update(contract.body[:book])
      expose book
    end

    def destroy
      book.destroy
      expose book
    end

    private

    attr_reader :book

    def set_book
      @book = Book.find(params[:id])
    end
  end
end
