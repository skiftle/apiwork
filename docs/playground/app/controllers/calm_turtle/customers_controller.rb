# frozen_string_literal: true

module CalmTurtle
  class CustomersController < ApplicationController
    def create
      customer = Customer.create(contract.body[:customer])
      expose({ customer: })
    end
  end
end
