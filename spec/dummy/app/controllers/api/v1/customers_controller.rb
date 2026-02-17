# frozen_string_literal: true

module Api
  module V1
    class CustomersController < V1Controller
      before_action :set_customer, only: %i[show update destroy]

      def index
        expose Customer.all
      end

      def show
        expose customer
      end

      def create
        params = sti_params(contract.body[:customer])
        customer = Customer.create(params)
        expose customer
      end

      def update
        params = sti_params(contract.body[:customer])
        customer.update(params)
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

      def sti_params(params)
        if params[:kind]
          params.merge(type: params.delete(:kind))
        else
          params
        end
      end
    end
  end
end
