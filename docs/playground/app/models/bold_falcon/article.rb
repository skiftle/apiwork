# frozen_string_literal: true

module BoldFalcon
  class Article < ApplicationRecord
    belongs_to :category, optional: true

    enum :status, { draft: 0, archived: 1, published: 2 }

    validates :title, presence: true
  end
end
