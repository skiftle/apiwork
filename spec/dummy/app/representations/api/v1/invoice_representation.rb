# frozen_string_literal: true

module Api
  module V1
    class InvoiceRepresentation < Apiwork::Representation::Base
      with_options filterable: true, sortable: true do
        attribute :created_at
        attribute :id
        attribute :updated_at

        with_options writable: true do
          attribute :due_on
          attribute :metadata
          attribute :notes, description: 'Payment terms and notes'
          attribute :number
          attribute :sent
          attribute :status
        end
      end

      attribute :customer_id, writable: true

      has_many :attachments
      has_many :items, writable: true
      has_many :payments
      has_many :taggings, filterable: true, sortable: true
    end
  end
end
