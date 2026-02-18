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

  enum :status, { draft: 0, sent: 1, paid: 2, overdue: 3, void: 4 } # rubocop:disable Apiwork/SortHash

  validates :number, length: { maximum: 20, minimum: 3 }, presence: true, uniqueness: true
  validate :validate_number_format

  private

  def validate_number_format
    return if number.blank?
    return if number.start_with?('INV-')

    errors.add(:base, :invalid, message: 'number must start with INV-')
    errors.add(:number, :billing_format)
  end
end
