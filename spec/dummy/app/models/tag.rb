# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :invoices, source: :taggable, source_type: 'Invoice', through: :taggings
  has_many :customers, source: :taggable, source_type: 'Customer', through: :taggings

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
