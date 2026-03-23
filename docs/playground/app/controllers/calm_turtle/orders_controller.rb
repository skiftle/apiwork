# frozen_string_literal: true

module CalmTurtle
  class OrdersController < ApplicationController
    def create
      order = Order.create(contract.body[:order])
      expose({ order: order.as_json })
    end
  end
end
