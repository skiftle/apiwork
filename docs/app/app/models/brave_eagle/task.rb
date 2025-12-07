# frozen_string_literal: true

module BraveEagle
  class Task < ApplicationRecord
    validates :title, presence: true

    def archive!
      update!(archived: true)
    end
  end
end
