# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < V1Controller
      before_action :set_payment, only: %i[show update destroy]

      def index
        expose Payment.all
      end

      def show
        expose payment
      end

      def create
        payment = Payment.create(contract.body[:payment])
        expose payment
      end

      def update
        payment.update(contract.body[:payment])
        expose payment
      end

      def destroy
        payment.destroy
        expose payment
      end

      private

      attr_reader :payment

      def set_payment
        @payment = Payment.find(params[:id])
      end
    end
  end
end
