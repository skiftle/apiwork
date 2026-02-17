# frozen_string_literal: true

module Api
  module V1
    class PaymentRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :amount, writable: true
      attribute :method, writable: true, filterable: true
      attribute :status, filterable: true
      attribute :reference, writable: true
      attribute :paid_at
      attribute :created_at
      attribute :updated_at

      belongs_to :invoice
      belongs_to :customer
    end
  end
end
