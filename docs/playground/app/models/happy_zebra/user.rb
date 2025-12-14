# frozen_string_literal: true

module HappyZebra
  class User < ApplicationRecord
    has_one :profile, dependent: :destroy
    has_many :posts, dependent: :destroy

    accepts_nested_attributes_for :profile
    accepts_nested_attributes_for :posts

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :username, presence: true, length: { minimum: 3, maximum: 20 }
  end
end
