# frozen_string_literal: true

module HappyZebra
  class Profile < ApplicationRecord
    belongs_to :user

    validates :bio, length: { maximum: 500 }
    validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  end
end
