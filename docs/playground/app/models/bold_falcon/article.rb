# frozen_string_literal: true

module BoldFalcon
  class Article < ApplicationRecord
    belongs_to :category, optional: true

    enum :status,
         {
           archived: 'archived',
           draft: 'draft',
           published: 'published',
         }

    validates :title, presence: true
  end
end
