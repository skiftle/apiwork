# frozen_string_literal: true

module SwiftFox
  class Post < ApplicationRecord
    self.table_name = 'swift_fox_posts'

    enum :status, { draft: 'draft', published: 'published', archived: 'archived' }

    validates :title, presence: true
  end
end
