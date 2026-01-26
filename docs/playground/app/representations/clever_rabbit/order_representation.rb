# frozen_string_literal: true

module CleverRabbit
  class OrderRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :order_number, writable: true
    attribute :status, filterable: true, sortable: true
    attribute :total
    attribute :created_at, sortable: true
    attribute :updated_at

    has_many :line_items, include: :always, writable: true
    has_one :shipping_address, include: :always, writable: true
  end
end
