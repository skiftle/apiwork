# frozen_string_literal: true

module Api
  module V1
    class UsersController < V1Controller
      before_action :set_user, only: %i[show update destroy]

      def index
        expose User.all
      end

      def show
        expose user
      end

      def create
        user = User.create(contract.body[:user])
        expose user
      end

      def update
        user.update(contract.body[:user])
        expose user
      end

      def destroy
        user.destroy
        expose user
      end

      private

      attr_reader :user

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
