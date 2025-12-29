# frozen_string_literal: true

module BraveEagle
  class User < ApplicationRecord
    has_many :assigned_tasks,
             class_name: 'Task',
             dependent: :nullify,
             foreign_key: :assignee_id,
             inverse_of: :assignee
  end
end
