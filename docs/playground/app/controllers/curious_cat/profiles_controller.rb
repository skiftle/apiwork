# frozen_string_literal: true

module CuriousCat
  class ProfilesController < ApplicationController
    before_action :set_profile, only: %i[show update destroy]

    def index
      profiles = Profile.all
      respond profiles
    end

    def show
      respond profile
    end

    def create
      profile = Profile.create(contract.body[:profile])
      respond profile
    end

    def update
      profile.update(contract.body[:profile])
      respond profile
    end

    def destroy
      profile.destroy
      respond profile
    end

    private

    attr_reader :profile

    def set_profile
      @profile = Profile.find(params[:id])
    end
  end
end
