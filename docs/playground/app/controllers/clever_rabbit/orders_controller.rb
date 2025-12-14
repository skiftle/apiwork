# frozen_string_literal: true

module CleverRabbit
  class OrdersController < ApplicationController
    before_action :set_order, only: %i[show update destroy]

    def index
      orders = Order.all
      respond orders
    end

    def show
      respond order
    end

    def create
      order = Order.create(contract.body[:order])
      respond order
    end

    def update
      order.update(contract.body[:order])
      respond order
    end

    def destroy
      order.destroy
      respond order
    end

    private

    attr_reader :order

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
