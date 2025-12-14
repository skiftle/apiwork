# frozen_string_literal: true

module HappyZebra
  class Post < ApplicationRecord
    belongs_to :user
    has_many :comments, dependent: :destroy

    accepts_nested_attributes_for :comments

    validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  end
end
