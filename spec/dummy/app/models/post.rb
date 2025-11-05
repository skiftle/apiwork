# frozen_string_literal: true

class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, allow_destroy: true

  validates :title, presence: true
end
