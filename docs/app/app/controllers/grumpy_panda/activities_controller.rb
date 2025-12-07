# frozen_string_literal: true

module GrumpyPanda
  class ActivitiesController < ApplicationController
    before_action :set_activity, only: %i[show update destroy]

    def index
      activities = Activity.all
      respond_with activities
    end

    def show
      respond_with activity
    end

    def create
      activity = Activity.create(contract.body[:activity])
      respond_with activity
    end

    def update
      activity.update(contract.body[:activity])
      respond_with activity
    end

    def destroy
      activity.destroy
      respond_with activity
    end

    private

    attr_reader :activity

    def set_activity
      @activity = Activity.find(params[:id])
    end
  end
end
