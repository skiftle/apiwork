# frozen_string_literal: true

module CleverRabbit
  class OrdersController < ApplicationController
    before_action :set_order, only: %i[show update destroy]

    def index
      orders = Order.all
      render_with_contract orders
    end

    def show
      render_with_contract order
    end

    def create
      order = Order.create(contract.body[:order])
      render_with_contract order
    end

    def update
      order.update(contract.body[:order])
      render_with_contract order
    end

    def destroy
      order.destroy
      render_with_contract order
    end

    private

    attr_reader :order

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
