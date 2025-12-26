# frozen_string_literal: true

module CuriousCat
  class ProfilesController < ApplicationController
    before_action :set_profile, only: %i[show update destroy]

    def index
      profiles = Profile.all
      expose profiles
    end

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
      @profile = Profile.find(params[:id])
    end
  end
end
