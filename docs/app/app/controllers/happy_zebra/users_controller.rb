# frozen_string_literal: true

module HappyZebra
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show update destroy]

    def index
      users = User.all
      respond_with users
    end

    def show
      respond_with user
    end

    def create
      user = User.create(contract.body[:user])
      respond_with user
    end

    def update
      user.update(contract.body[:user])
      respond_with user
    end

    def destroy
      user.destroy
      respond_with user
    end

    private

    attr_reader :user

    def set_user
      @user = User.find(params[:id])
    end
  end
end
