# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < V1Controller
      before_action :set_author, only: %i[show update destroy]

      def index
        expose Author.all
      end

      def show
        expose author
      end

      def create
        author = Author.create(contract.body[:author])
        expose author
      end

      def update
        author.update(contract.body[:author])
        expose author
      end

      def destroy
        author.destroy
        expose author
      end

      private

      attr_reader :author

      def set_author
        @author = Author.find(params[:id])
      end
    end
  end
end
