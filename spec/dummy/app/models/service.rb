# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :customer

  validates :name, presence: true
end
