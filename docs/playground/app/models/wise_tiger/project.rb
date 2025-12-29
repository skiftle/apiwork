# frozen_string_literal: true

module WiseTiger
  class Project < ApplicationRecord
    enum :status,
         {
           active: 'active',
           archived: 'archived',
           completed: 'completed',
           paused: 'paused'
         }
    enum :priority,
         {
           critical: 'critical',
           high: 'high',
           low: 'low',
           medium: 'medium'
         }

    validates :name, presence: true
  end
end
