# frozen_string_literal: true

class Adjustment < ApplicationRecord
  belongs_to :item

  validates :description, presence: true
end
