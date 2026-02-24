# frozen_string_literal: true

module HappyZebra
  class Comment < ApplicationRecord
    belongs_to :post

    validates :body, length: { maximum: 500 }, presence: true
    validates :author, presence: true
  end
end
