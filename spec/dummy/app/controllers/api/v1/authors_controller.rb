# frozen_string_literal: true

module Api
  module V1
    class AuthorsController < V1Controller
      before_action :set_author, only: %i[show update destroy]

      def index
        render_with_contract Author.all
      end

      def show
        render_with_contract author
      end

      def create
        author = Author.create(contract.body[:author])
        render_with_contract author
      end

      def update
        author.update(contract.body[:author])
        render_with_contract author
      end

      def destroy
        author.destroy
        render_with_contract author
      end

      private

      attr_reader :author

      def set_author
        @author = Author.find(params[:id])
      end
    end
  end
end
