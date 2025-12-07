# frozen_string_literal: true

module CleverRabbit
  class Order < ApplicationRecord
    self.table_name = 'clever_rabbit_orders'

    has_many :line_items, dependent: :destroy
    has_one :shipping_address, dependent: :destroy

    accepts_nested_attributes_for :line_items, allow_destroy: true
    accepts_nested_attributes_for :shipping_address, allow_destroy: true

    validates :order_number, presence: true
  end
end
