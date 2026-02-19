# frozen_string_literal: true

module Api
  module V1
    class InvoicesController < V1Controller
      before_action :set_invoice, only: %i[show update destroy send_invoice void]

      def index
        expose Invoice.all
      end

      def show
        expose invoice
      end

      def create
        invoice = Invoice.create(contract.body[:invoice])
        expose invoice
      end

      def update
        invoice.update(contract.body[:invoice])
        expose invoice
      end

      def destroy
        invoice.destroy
        expose invoice
      end

      def send_invoice
        invoice.update(sent: true)
        expose invoice
      end

      def void
        invoice.update(status: :void)
        expose invoice
      end

      def search
        expose Invoice.search(contract.query[:q])
      end

      def bulk_create
        invoices = Invoice.create(contract.body[:invoices])
        expose Invoice.where(id: invoices.map(&:id)), status: :created
      end

      private

      attr_reader :invoice

      def set_invoice
        @invoice = Invoice.find(params[:id])
      end
    end
  end
end
