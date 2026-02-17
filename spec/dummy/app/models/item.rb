# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :invoice
  has_many :adjustments, dependent: :destroy

  accepts_nested_attributes_for :adjustments, allow_destroy: true

  validates :description, presence: true
end
