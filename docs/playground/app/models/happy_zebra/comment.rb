# frozen_string_literal: true

module HappyZebra
  class Comment < ApplicationRecord
    belongs_to :post

    validates :body, presence: true, length: { minimum: 1, maximum: 500 }
    validates :author, presence: true
  end
end
