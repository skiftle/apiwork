# frozen_string_literal: true

module HappyZebra
  class Profile < ApplicationRecord
    belongs_to :user

    validates :bio, length: { maximum: 500 }
    validates :website, allow_blank: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  end
end
