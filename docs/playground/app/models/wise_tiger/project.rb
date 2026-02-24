# frozen_string_literal: true

module WiseTiger
  class Project < ApplicationRecord
    enum :status, { active: 0, archived: 1, completed: 2, paused: 3 }
    enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }

    validates :name, presence: true
  end
end
