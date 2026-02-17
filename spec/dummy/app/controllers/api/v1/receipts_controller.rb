# frozen_string_literal: true

module Api
  module V1
    class ReceiptsController < V1Controller
      def index
        expose Invoice.all
      end

      def show
        receipt = Invoice.find(params[:id])
        expose receipt
      end

      def create
        receipt = Invoice.new(contract.body[:receipt])
        receipt.notes = "Auto-generated receipt"
        receipt.save
        expose receipt
      end

      def update
        receipt = Invoice.find(params[:id])
        receipt.update(contract.body[:receipt])
        expose receipt
      end

      def destroy
        receipt = Invoice.find(params[:id])
        receipt.destroy
        expose receipt
      end
    end
  end
end
