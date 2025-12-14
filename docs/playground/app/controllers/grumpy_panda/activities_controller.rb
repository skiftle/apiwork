# frozen_string_literal: true

module GrumpyPanda
  class ActivitiesController < ApplicationController
    before_action :set_activity, only: %i[show update destroy]

    def index
      activities = Activity.all
      respond activities
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
