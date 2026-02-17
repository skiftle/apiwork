# frozen_string_literal: true

module Api
  module V2
    class CustomerAddressesController < V2Controller
      before_action :set_address, only: %i[show update destroy]

      def index
        expose Address.all
      end

      def show
        expose address
      end

      def create
        customer = Customer.first || Customer.create!(name: 'Default Customer')
        address = Address.create!(contract.body[:customer_address].merge(customer:))
        expose address
      end

      def update
        address.update!(contract.body[:customer_address])
        expose address
      end

      def destroy
        address.destroy!
        head :no_content
      end

      private

      attr_reader :address

      def set_address
        @address = Address.find(params[:id])
      end
    end
  end
end
