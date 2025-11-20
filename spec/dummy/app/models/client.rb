# frozen_string_literal: true

class Client < ApplicationRecord
  has_many :services, dependent: :destroy

  validates :name, presence: true
  validates :type, presence: true
end
