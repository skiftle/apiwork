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
        query_string = contract.query[:q]
        invoices = if query_string.present?
          Invoice.where('number LIKE ? OR notes LIKE ?', "%#{query_string}%", "%#{query_string}%")
        else
          Invoice.all
        end
        expose invoices
      end

      def bulk_create
        invoices_params = contract.body[:invoices] || []
        created_ids = invoices_params.map do |invoice_params|
          record = Invoice.create(
            number: invoice_params[:number],
            customer_id: invoice_params[:customer_id],
            sent: invoice_params[:sent] || false
          )
          record.id
        end
        invoices = Invoice.where(id: created_ids)
        expose invoices, status: :created
      end

      private

      attr_reader :invoice

      def set_invoice
        @invoice = Invoice.find(params[:id])
      end
    end
  end
end
