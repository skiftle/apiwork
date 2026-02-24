# frozen_string_literal: true

module HappyZebra
  class User < ApplicationRecord
    has_many :posts, dependent: :destroy
    has_one :profile, dependent: :destroy

    accepts_nested_attributes_for :posts
    accepts_nested_attributes_for :profile

    validates :email, format: { with: /@/ }, presence: true
    validates :username, length: { maximum: 20, minimum: 3 }, presence: true
    validate :validate_username_differs_from_email

    private

    def validate_username_differs_from_email
      return unless username.present? && email.present?
      return unless username == email

      errors.add(:base, :conflict)
    end
  end
end
