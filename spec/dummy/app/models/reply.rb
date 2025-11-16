# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :comment

  validates :content, presence: true
  validates :author, presence: true
end
