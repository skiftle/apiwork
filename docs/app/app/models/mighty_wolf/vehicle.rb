# frozen_string_literal: true

module MightyWolf
  class Vehicle < ApplicationRecord
    self.table_name = 'mighty_wolf_vehicles'

    validates :brand, :model, presence: true
  end
end
