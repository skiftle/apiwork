# frozen_string_literal: true

module EagerLion
  class InvoicesController < ApplicationController
    before_action :set_invoice, only: %i[show update destroy archive]

    def index
      invoices = Invoice.all
      respond invoices
    end

    def show
      respond invoice
    end

    def create
      invoice = Invoice.create(contract.body[:invoice])
      respond invoice
    end

    def update
      invoice.update(contract.body[:invoice])
      respond invoice
    end

    def destroy
      invoice.destroy
      respond invoice
    end

    def archive
      invoice.update(archived: true)
      respond invoice
    end

    private

    attr_reader :invoice

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end
  end
end
