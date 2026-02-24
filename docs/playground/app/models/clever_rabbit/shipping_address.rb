# frozen_string_literal: true

module CleverRabbit
  class ShippingAddress < ApplicationRecord
    belongs_to :order

    validates :street, :city, :postal_code, :country, presence: true
  end
end
