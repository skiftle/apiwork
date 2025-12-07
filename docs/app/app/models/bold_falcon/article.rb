# frozen_string_literal: true

module BoldFalcon
  class Article < ApplicationRecord
    self.table_name = 'bold_falcon_articles'

    belongs_to :category, optional: true

    enum :status, { draft: 'draft', published: 'published', archived: 'archived' }

    validates :title, presence: true
  end
end
