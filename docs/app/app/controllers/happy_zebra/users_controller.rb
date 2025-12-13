# frozen_string_literal: true

module HappyZebra
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show update destroy]

    def index
      users = User.all
      render_with_contract users
    end

    def show
      render_with_contract user
    end

    def create
      user = User.create(contract.body[:user])
      render_with_contract user
    end

    def update
      user.update(contract.body[:user])
      render_with_contract user
    end

    def destroy
      user.destroy
      render_with_contract user
    end

    private

    attr_reader :user

    def set_user
      @user = User.find(params[:id])
    end
  end
end
