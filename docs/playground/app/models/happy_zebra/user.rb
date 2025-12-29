# frozen_string_literal: true

module HappyZebra
  class User < ApplicationRecord
    has_one :profile, dependent: :destroy
    has_many :posts, dependent: :destroy

    accepts_nested_attributes_for :profile
    accepts_nested_attributes_for :posts

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
    validates :username, length: { maximum: 20, minimum: 3 }, presence: true
  end
end
