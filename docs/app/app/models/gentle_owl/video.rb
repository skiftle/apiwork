# frozen_string_literal: true

module GentleOwl
  class Video < ApplicationRecord
    self.table_name = 'gentle_owl_videos'

    has_many :comments, as: :commentable, dependent: :destroy

    validates :title, :url, presence: true
  end
end
