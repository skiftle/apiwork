# frozen_string_literal: true

module LoyalHound
  class Review < ApplicationRecord
    belongs_to :book

    validates :rating, presence: true
  end
end
