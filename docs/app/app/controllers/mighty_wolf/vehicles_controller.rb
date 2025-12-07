# frozen_string_literal: true

module MightyWolf
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: %i[show update destroy]

    def index
      vehicles = Vehicle.all
      respond_with vehicles
    end

    def show
      respond_with vehicle
    end

    def create
      vehicle = Vehicle.create(contract.body[:vehicle])
      respond_with vehicle
    end

    def update
      vehicle.update(contract.body[:vehicle])
      respond_with vehicle
    end

    def destroy
      vehicle.destroy
      respond_with vehicle
    end

    private

    attr_reader :vehicle

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end
  end
end
