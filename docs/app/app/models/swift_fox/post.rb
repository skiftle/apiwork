# frozen_string_literal: true

module SwiftFox
  class Post < ApplicationRecord
    enum :status, { draft: 'draft', published: 'published', archived: 'archived' }

    validates :title, presence: true
  end
end
