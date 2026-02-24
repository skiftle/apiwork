# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  validates :tag_id, presence: true
  validates :taggable_type, presence: true
  validates :taggable_id, presence: true
  validates :tag_id, uniqueness: { scope: [:taggable_type, :taggable_id] }
end
