# frozen_string_literal: true

module FunnySnake
  class InvoicesController < ApplicationController
    before_action :set_invoice, only: %i[show update destroy]

    def index
      invoices = Invoice.all
      respond({ invoices: invoices.map { |i| serialize_invoice(i) } })
    end

    def show
      respond({ invoice: serialize_invoice(invoice) })
    end

    def create
      invoice = Invoice.create(contract.body[:invoice])
      respond({ invoice: serialize_invoice(invoice) })
    end

    def update
      invoice.update(contract.body[:invoice])
      respond({ invoice: serialize_invoice(invoice) })
    end

    def destroy
      invoice.destroy
      no_content!
    end

    private

    attr_reader :invoice

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def serialize_invoice(invoice)
      {
        id: invoice.id,
        number: invoice.number,
        issued_on: invoice.issued_on,
        status: invoice.status,
        notes: invoice.notes,
        created_at: invoice.created_at,
        updated_at: invoice.updated_at
      }
    end
  end
end
