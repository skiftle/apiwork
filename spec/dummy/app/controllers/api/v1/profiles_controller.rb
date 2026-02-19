# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < V1Controller
      before_action :set_profile, only: %i[show update destroy]

      def show
        expose profile
      end

      def create
        profile = Profile.create(contract.body[:profile])
        expose profile
      end

      def update
        profile.update(contract.body[:profile])
        expose profile
      end

      def destroy
        profile.destroy
        expose profile
      end

      private

      attr_reader :profile

      def set_profile
        @profile = Profile.first
        raise ActiveRecord::RecordNotFound unless @profile
      end
    end
  end
end
