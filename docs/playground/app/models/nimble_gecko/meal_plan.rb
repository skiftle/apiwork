# frozen_string_literal: true

module NimbleGecko
  class MealPlan < ApplicationRecord
    has_many :cooking_steps, dependent: :destroy

    accepts_nested_attributes_for :cooking_steps, allow_destroy: true

    validates :title, presence: true
  end
end
