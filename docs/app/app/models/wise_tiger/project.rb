# frozen_string_literal: true

module WiseTiger
  class Project < ApplicationRecord
    enum :status, { active: 'active', paused: 'paused', completed: 'completed', archived: 'archived' }
    enum :priority, { low: 'low', medium: 'medium', high: 'high', critical: 'critical' }

    validates :name, presence: true
  end
end
