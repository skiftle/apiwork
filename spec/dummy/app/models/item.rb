# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :invoice
  has_many :adjustments, dependent: :destroy

  accepts_nested_attributes_for :adjustments, allow_destroy: true

  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0, less_than: 10_000, only_integer: true }
  validates :unit_price, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }
end
