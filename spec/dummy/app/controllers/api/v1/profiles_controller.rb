# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < V1Controller
      before_action :set_profile, only: %i[show update destroy]

      def show
        expose profile
      end

      def create
        profile = current_user.create_profile!(contract.body[:profile])
        expose profile
      end

      def update
        profile.update!(contract.body[:profile])
        expose profile
      end

      def destroy
        profile.destroy!
        head :no_content
      end

      private

      attr_reader :profile

      def set_profile
        @profile = current_user.profile
        raise ActiveRecord::RecordNotFound unless @profile
      end

      def current_user
        @current_user ||= User.first || User.create!(name: 'Test User', email: 'test@example.com')
      end
    end
  end
end
