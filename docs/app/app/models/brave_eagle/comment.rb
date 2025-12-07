# frozen_string_literal: true

module BraveEagle
  class Comment < ApplicationRecord
    belongs_to :task
  end
end
