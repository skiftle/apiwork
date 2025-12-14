# frozen_string_literal: true

module GentleOwl
  class Comment < ApplicationRecord
    belongs_to :commentable, polymorphic: true

    validates :body, presence: true
  end
end
