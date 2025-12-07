# frozen_string_literal: true

module BoldFalcon
  class Category < ApplicationRecord
    self.table_name = 'bold_falcon_categories'

    has_many :articles, dependent: :nullify

    validates :name, :slug, presence: true
  end
end
