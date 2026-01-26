# frozen_string_literal: true

module BraveEagle
  class TaskRepresentation < Apiwork::Representation::Base
    description 'A task representing work to be completed'

    attribute :id, description: 'Unique task identifier'

    attribute :title, description: 'Short title describing the task', example: 'Implement user authentication', writable: true

    attribute :description,
              description: 'Detailed description of what needs to be done',
              example: 'Add OAuth2 login support for Google and GitHub providers',
              writable: true

    attribute :status,
              description: 'Current status of the task',
              enum: %w[pending in_progress completed archived],
              example: 'pending',
              filterable: true,
              writable: true

    attribute :priority,
              description: 'Priority level for task ordering',
              enum: %w[low medium high critical],
              example: 'high',
              filterable: true,
              writable: true

    attribute :due_date, description: 'Target date for task completion', example: '2024-02-01T00:00:00Z', sortable: true, writable: true

    attribute :archived, deprecated: true, description: 'Whether the task has been archived'

    attribute :created_at, description: 'Timestamp when the task was created', sortable: true

    attribute :updated_at, description: 'Timestamp of last modification'

    belongs_to :assignee, description: 'User responsible for completing this task', optional: true, representation: BraveEagle::UserRepresentation

    has_many :comments, description: 'Discussion comments on this task', representation: BraveEagle::CommentRepresentation
  end
end
