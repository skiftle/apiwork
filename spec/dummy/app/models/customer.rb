# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :invoices
  has_many :services, dependent: :destroy
  has_one :address, dependent: :destroy
  has_many :payments
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :activities, as: :target, dependent: :destroy

  validates :name, presence: true
end
