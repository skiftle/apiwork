# frozen_string_literal: true

module FunnySnake
  class InvoicesController < ApplicationController
    before_action :set_invoice, only: %i[show update destroy]

    def index
      invoices = Invoice.all
      respond({ invoices: invoices.map(&:as_json) })
    end

    def show
      respond({ invoice: invoice.as_json })
    end

    def create
      invoice = Invoice.create(contract.body[:invoice])

      respond({ invoice: invoice.as_json })
    end

    def update
      invoice.update(contract.body[:invoice])
      respond({ invoice: invoice.as_json })
    end

    def destroy
      invoice.destroy
      respond invoice
    end

    private

    attr_reader :invoice

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end
  end
end
