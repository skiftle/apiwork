# frozen_string_literal: true

module Api
  module V1
    class InvoiceRepresentation < Apiwork::Representation::Base
      with_options filterable: true, sortable: true do
        attribute :id
        attribute :created_at
        attribute :updated_at

        with_options writable: true do
          attribute :number
          attribute :status
          attribute :due_on
          attribute :notes, description: 'Payment terms and notes'
          attribute :metadata
          attribute :sent
        end
      end

      attribute :customer_id, writable: true

      has_many :items, representation: ItemRepresentation, writable: true
      has_many :attachments
      has_many :payments
      has_many :taggings, representation: TaggingRepresentation, filterable: true, sortable: true
    end
  end
end
