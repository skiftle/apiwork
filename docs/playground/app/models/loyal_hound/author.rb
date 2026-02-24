# frozen_string_literal: true

module LoyalHound
  class Author < ApplicationRecord
    has_many :books, dependent: :destroy

    validates :name, presence: true
  end
end
