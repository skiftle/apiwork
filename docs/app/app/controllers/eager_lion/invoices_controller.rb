# frozen_string_literal: true

module EagerLion
  class InvoicesController < ApplicationController
    before_action :set_invoice, only: %i[show update destroy archive]

    def index
      invoices = Invoice.all
      render_with_contract invoices
    end

    def show
      render_with_contract invoice
    end

    def create
      invoice = Invoice.create(contract.body[:invoice])
      render_with_contract invoice
    end

    def update
      invoice.update(contract.body[:invoice])
      render_with_contract invoice
    end

    def destroy
      invoice.destroy
      render_with_contract invoice
    end

    def archive
      invoice.update(archived: true)
      render_with_contract invoice
    end

    private

    attr_reader :invoice

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end
  end
end
