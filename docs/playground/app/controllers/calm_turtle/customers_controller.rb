# frozen_string_literal: true

module CalmTurtle
  class CustomersController < ApplicationController
    before_action :set_customer, only: %i[show update destroy]

    def index
      customers = Customer.all
      expose customers
    end

    def show
      expose customer
    end

    def create
      customer = Customer.create(contract.body[:customer])
      expose customer
    end

    def update
      customer.update(contract.body[:customer])
      expose customer
    end

    def destroy
      customer.destroy
      expose customer
    end

    private

    attr_reader :customer

    def set_customer
      @customer = Customer.find(params[:id])
    end
  end
end
