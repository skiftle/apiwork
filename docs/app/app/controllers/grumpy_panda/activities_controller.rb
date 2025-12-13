# frozen_string_literal: true

module GrumpyPanda
  class ActivitiesController < ApplicationController
    before_action :set_activity, only: %i[show update destroy]

    def index
      activities = Activity.all
      render_with_contract activities
    end

    def show
      render_with_contract activity
    end

    def create
      activity = Activity.create(contract.body[:activity])
      render_with_contract activity
    end

    def update
      activity.update(contract.body[:activity])
      render_with_contract activity
    end

    def destroy
      activity.destroy
      render_with_contract activity
    end

    private

    attr_reader :activity

    def set_activity
      @activity = Activity.find(params[:id])
    end
  end
end
