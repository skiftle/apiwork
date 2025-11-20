# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :client

  validates :name, presence: true
end
