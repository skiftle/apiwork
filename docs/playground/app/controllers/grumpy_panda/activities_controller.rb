# frozen_string_literal: true

module GrumpyPanda
  class ActivitiesController < ApplicationController
    before_action :set_activity, only: %i[show update destroy]

    def index
      activities = Activity.all
      expose activities
    end

    def show
      expose activity
    end

    def create
      activity = Activity.create(contract.body[:activity])
      expose activity
    end

    def update
      activity.update(contract.body[:activity])
      expose activity
    end

    def destroy
      activity.destroy
      expose activity
    end

    private

    attr_reader :activity

    def set_activity
      @activity = Activity.find(params[:id])
    end
  end
end
