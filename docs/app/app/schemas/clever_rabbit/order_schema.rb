# frozen_string_literal: true

module CleverRabbit
  class OrderSchema < Apiwork::Schema::Base
    attribute :id
    attribute :order_number, writable: true
    attribute :status, filterable: true, sortable: true
    attribute :total
    attribute :created_at, sortable: true
    attribute :updated_at

    has_many :line_items, writable: true, include: :always
    has_one :shipping_address, writable: true, include: :always
  end
end
