# frozen_string_literal: true

module BraveEagle
  class TaskSchema < Apiwork::Schema::Base
    description 'A task representing work to be completed'

    attribute :id, description: 'Unique task identifier'

    attribute :title, description: 'Short title describing the task', example: 'Implement user authentication', writable: true

    attribute :description,
              writable: true,
              description: 'Detailed description of what needs to be done',
              example: 'Add OAuth2 login support for Google and GitHub providers'

    attribute :status,
              writable: true,
              filterable: true,
              description: 'Current status of the task',
              example: 'pending',
              enum: %w[pending in_progress completed archived]

    attribute :priority,
              writable: true,
              filterable: true,
              description: 'Priority level for task ordering',
              example: 'high',
              enum: %w[low medium high critical]

    attribute :due_date, description: 'Target date for task completion', example: '2024-02-01T00:00:00Z', sortable: true, writable: true

    attribute :archived, deprecated: true, description: 'Whether the task has been archived'

    attribute :created_at, description: 'Timestamp when the task was created', sortable: true

    attribute :updated_at, description: 'Timestamp of last modification'

    belongs_to :assignee, class_name: BraveEagle::UserSchema, description: 'User responsible for completing this task', optional: true

    has_many :comments, class_name: BraveEagle::CommentSchema, description: 'Discussion comments on this task'
  end
end
