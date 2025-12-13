# frozen_string_literal: true

module Api
  module V1
    class ActivitiesController < V1Controller
      before_action :set_activity, only: %i[show update destroy]

      def index
        respond Activity.all
      end

      def show
        respond activity
      end

      def create
        activity = Activity.create(contract.body[:activity])
        respond activity
      end

      def update
        activity.update(contract.body[:activity])
        respond activity
      end

      def destroy
        activity.destroy
        respond activity
      end

      private

      attr_reader :activity

      def set_activity
        @activity = Activity.find(params[:id])
      end
    end
  end
end
