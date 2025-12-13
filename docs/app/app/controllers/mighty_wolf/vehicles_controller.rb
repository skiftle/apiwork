# frozen_string_literal: true

module MightyWolf
  class VehiclesController < ApplicationController
    before_action :set_vehicle, only: %i[show update destroy]

    def index
      vehicles = Vehicle.all
      render_with_contract vehicles
    end

    def show
      render_with_contract vehicle
    end

    def create
      vehicle = Vehicle.create(contract.body[:vehicle])
      render_with_contract vehicle
    end

    def update
      vehicle.update(contract.body[:vehicle])
      render_with_contract vehicle
    end

    def destroy
      vehicle.destroy
      render_with_contract vehicle
    end

    private

    attr_reader :vehicle

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end
  end
end
