# frozen_string_literal: true

module Api
  module V1
    class ItemRepresentation < Apiwork::Representation::Base
      with_options filterable: true, sortable: true do
        attribute :created_at
        attribute :id
        attribute :updated_at

        with_options writable: true do
          attribute :description
          attribute :quantity
          attribute :unit_price
        end
      end

      attribute :invoice_id, writable: true

      has_many :adjustments, writable: true
      belongs_to :invoice, filterable: true, sortable: true
    end
  end
end
