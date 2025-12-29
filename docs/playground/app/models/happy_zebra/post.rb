# frozen_string_literal: true

module HappyZebra
  class Post < ApplicationRecord
    belongs_to :user
    has_many :comments, dependent: :destroy

    accepts_nested_attributes_for :comments

    validates :title, length: { maximum: 100, minimum: 3 }, presence: true
  end
end
