# frozen_string_literal: true

module CleverRabbit
  class OrdersController < ApplicationController
    before_action :set_order, only: %i[show update destroy]

    def index
      orders = Order.all
      respond_with orders
    end

    def show
      respond_with order
    end

    def create
      order = Order.create(contract.body[:order])
      respond_with order
    end

    def update
      order.update(contract.body[:order])
      respond_with order
    end

    def destroy
      order.destroy
      respond_with order
    end

    private

    attr_reader :order

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
