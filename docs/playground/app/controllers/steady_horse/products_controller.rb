# frozen_string_literal: true

module SteadyHorse
  class ProductsController < ApplicationController
    before_action :set_product, only: %i[show update destroy]

    def index
      products = Product.all
      expose products
    end

    def show
      expose product
    end

    def create
      product = Product.create(contract.body[:product])
      expose product
    end

    def update
      product.update(contract.body[:product])
      expose product
    end

    def destroy
      product.destroy
      expose product
    end

    private

    attr_reader :product

    def set_product
      @product = Product.find(params[:id])
    end
  end
end
