# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'
  has_many :comments, through: :taggings, source: :taggable, source_type: 'Comment'
  has_many :authors, through: :taggings, source: :taggable, source_type: 'Author'

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
