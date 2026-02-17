# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :invoices, through: :taggings, source: :taggable, source_type: 'Invoice'
  has_many :customers, through: :taggings, source: :taggable, source_type: 'Customer'

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
