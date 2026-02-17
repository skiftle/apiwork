# frozen_string_literal: true

module Api
  module InferenceTest
    class InvoicesController < InferenceTestController
      def index
        expose Invoice.all
      end

      def show
        expose Invoice.find(params[:id])
      end

      def create
        invoice = Invoice.create(contract.body[:invoice])
        expose invoice
      end

      def update
        invoice = Invoice.find(params[:id])
        invoice.update(contract.body[:invoice])
        expose invoice
      end

      def destroy
        invoice = Invoice.find(params[:id])
        invoice.destroy
        expose invoice
      end
    end
  end
end
