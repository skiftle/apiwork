# frozen_string_literal: true

module GentleOwl
  class Video < ApplicationRecord
    has_many :comments, as: :commentable, dependent: :destroy

    validates :title, :url, presence: true
  end
end
