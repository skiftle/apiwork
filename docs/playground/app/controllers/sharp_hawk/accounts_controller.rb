# frozen_string_literal: true

module SharpHawk
  class AccountsController < ApplicationController
    before_action :set_account, only: %i[show update destroy]

    def index
      accounts = Account.all
      expose accounts
    end

    def show
      expose account
    end

    def create
      account = Account.create(contract.body[:account])
      expose account
    end

    def update
      account.update(contract.body[:account])
      expose account
    end

    def destroy
      account.destroy
      expose account
    end

    private

    attr_reader :account

    def set_account
      @account = Account.find(params[:id])
    end
  end
end
