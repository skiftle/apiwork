# frozen_string_literal: true

module Api
  module OverrideTest
    class InvoiceRepresentation < ApplicationRepresentation
      attribute :id
      attribute :number, writable: true
      attribute :status
    end
  end
end
