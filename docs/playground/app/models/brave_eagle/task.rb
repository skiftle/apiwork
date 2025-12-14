# frozen_string_literal: true

module BraveEagle
  class Task < ApplicationRecord
    belongs_to :assignee, class_name: 'User', optional: true, inverse_of: :assigned_tasks
    has_many :comments, dependent: :destroy

    validates :title, presence: true

    def archive!
      update!(archived: true)
    end
  end
end
