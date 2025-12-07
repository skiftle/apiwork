# frozen_string_literal: true

module GentleOwl
  class Post < ApplicationRecord
    self.table_name = 'gentle_owl_posts'

    has_many :comments, as: :commentable, dependent: :destroy

    validates :title, presence: true
  end
end
