# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :items, dependent: :destroy
  has_many :payments
  has_many :attachments, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :activities, as: :target, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true

  enum :status, { draft: 0, sent: 1, paid: 2, overdue: 3, void: 4 }

  validates :number, presence: true
end
