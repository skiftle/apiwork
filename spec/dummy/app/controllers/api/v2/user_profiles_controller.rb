# frozen_string_literal: true

module Api
  module V2
    class UserProfilesController < V2Controller
      before_action :set_user_profile, only: %i[show update destroy]

      def index
        expose UserProfile.all
      end

      def show
        expose user_profile
      end

      def create
        user = User.first || User.create!(name: 'Test', email: 'test@example.com')
        profile = UserProfile.create!(contract.body[:user_profile].merge(user:))
        expose profile
      end

      def update
        user_profile.update!(contract.body[:user_profile])
        expose user_profile
      end

      def destroy
        user_profile.destroy!
        head :no_content
      end

      private

      attr_reader :user_profile

      def set_user_profile
        @user_profile = UserProfile.find(params[:id])
      end
    end
  end
end
