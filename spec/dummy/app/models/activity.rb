# frozen_string_literal: true

class Activity < ApplicationRecord
  validates :action, presence: true
end
