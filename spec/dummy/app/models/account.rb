# frozen_string_literal: true

class Account < ApplicationRecord
  enum :status, { active: 0, inactive: 1, archived: 2 }
  enum :first_day_of_week, {
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 0
  }
end