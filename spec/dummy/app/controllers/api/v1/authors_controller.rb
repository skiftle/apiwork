# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < V1Controller
      before_action :set_author, only: %i[show update destroy]

      def index
        respond_with Author.all
      end

      def show
        respond_with author
      end

      def create
        author = Author.create(action_input[:author])
        respond_with author
      end

      def update
        author.update(action_input[:author])
        respond_with author
      end

      def destroy
        author.destroy
        respond_with author
      end

      private

      attr_reader :author

      def set_author
        @author = Author.find(params[:id])
      end
    end
  end
end
