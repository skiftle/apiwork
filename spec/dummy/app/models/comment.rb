# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :post
  has_many :replies, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  accepts_nested_attributes_for :replies, allow_destroy: true

  validates :content, presence: true
end
