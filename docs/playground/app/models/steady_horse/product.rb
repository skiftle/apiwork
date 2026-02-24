# frozen_string_literal: true

module SteadyHorse
  class Product < ApplicationRecord
    validates :name, :price, :category, presence: true
  end
end
