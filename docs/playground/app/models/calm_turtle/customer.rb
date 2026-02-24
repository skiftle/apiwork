# frozen_string_literal: true

module CalmTurtle
  class Customer < ApplicationRecord
    has_many :orders, dependent: :destroy

    validates :name, presence: true
  end
end
