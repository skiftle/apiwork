# frozen_string_literal: true

module LoyalHound
  class Book < ApplicationRecord
    belongs_to :author
    has_many :reviews, dependent: :destroy

    validates :title, presence: true
  end
end
