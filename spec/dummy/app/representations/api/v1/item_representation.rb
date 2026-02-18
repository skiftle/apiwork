# frozen_string_literal: true

module Api
  module V1
    class ItemRepresentation < Apiwork::Representation::Base
      attribute :id, filterable: true, sortable: true
      attribute :description, writable: true, filterable: true, sortable: true
      attribute :quantity, filterable: true, sortable: true, writable: true
      attribute :unit_price, filterable: true, sortable: true, writable: true
      attribute :invoice_id, writable: true
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true

      belongs_to :invoice, filterable: true, sortable: true
      has_many :adjustments, writable: true
    end
  end
end
