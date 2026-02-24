# frozen_string_literal: true

module BoldFalcon
  class Category < ApplicationRecord
    has_many :articles, dependent: :nullify

    validates :name, :slug, presence: true
  end
end
