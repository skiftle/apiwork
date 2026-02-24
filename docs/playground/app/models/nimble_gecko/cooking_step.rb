# frozen_string_literal: true

module NimbleGecko
  class CookingStep < ApplicationRecord
    belongs_to :meal_plan

    validates :instruction, presence: true
    validates :step_number, presence: true
  end
end
