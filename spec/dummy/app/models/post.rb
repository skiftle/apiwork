# frozen_string_literal: true

class Post < ApplicationRecord
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  accepts_nested_attributes_for :comments, allow_destroy: true

  validates :title, presence: true
end
