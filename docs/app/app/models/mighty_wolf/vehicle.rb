# frozen_string_literal: true

module MightyWolf
  class Vehicle < ApplicationRecord
    validates :brand, :model, presence: true
  end
end
