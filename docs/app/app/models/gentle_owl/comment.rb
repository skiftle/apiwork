# frozen_string_literal: true

module GentleOwl
  class Comment < ApplicationRecord
    self.table_name = 'gentle_owl_comments'

    belongs_to :commentable, polymorphic: true

    validates :body, presence: true
  end
end
