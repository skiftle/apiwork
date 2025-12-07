# frozen_string_literal: true

module CleverRabbit
  class ShippingAddress < ApplicationRecord
    self.table_name = 'clever_rabbit_shipping_addresses'

    belongs_to :order

    validates :street, :city, :postal_code, :country, presence: true
  end
end
