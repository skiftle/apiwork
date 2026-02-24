# frozen_string_literal: true

module MightyWolf
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: %i[show update destroy]

    def index
      vehicles = Vehicle.all
      expose vehicles
    end

    def show
      expose vehicle
    end

    def create
      vehicle = Vehicle.create(contract.body[:vehicle])
      expose vehicle
    end

    def update
      vehicle.update(contract.body[:vehicle])
      expose vehicle
    end

    def destroy
      vehicle.destroy
      expose vehicle
    end

    private

    attr_reader :vehicle

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end
  end
end
