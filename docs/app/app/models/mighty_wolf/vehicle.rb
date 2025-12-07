# frozen_string_literal: true

module MightyWolf
  class Vehicle < ApplicationRecord
    validates :brand, :model, presence: true

    VARIANT_MAP = {
      'car' => 'MightyWolf::Car',
      'motorcycle' => 'MightyWolf::Motorcycle',
      'truck' => 'MightyWolf::Truck'
    }.freeze

    def kind=(value)
      self.type = VARIANT_MAP[value.to_s] || value
    end

    def kind
      type&.demodulize&.underscore
    end
  end
end
