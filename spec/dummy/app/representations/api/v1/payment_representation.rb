# frozen_string_literal: true

module Api
  module V1
    class PaymentRepresentation < ApplicationRepresentation
      with_options writable: true do
        attribute :amount
        attribute :method, filterable: true
        attribute :reference
      end

      attribute :created_at
      attribute :id
      attribute :paid_at
      attribute :status, filterable: true
      attribute :updated_at

      belongs_to :customer
      belongs_to :invoice
    end
  end
end
