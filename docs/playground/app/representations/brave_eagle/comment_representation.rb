# frozen_string_literal: true

module BraveEagle
  class CommentRepresentation < Apiwork::Representation::Base
    description 'A comment on a task'

    attribute :id, description: 'Unique comment identifier'

    attribute :body, description: 'Comment content', example: 'This looks good, ready for review.', writable: true

    attribute :author_name, description: 'Name of the person who wrote the comment', example: 'John Doe', writable: true

    attribute :created_at, description: 'When the comment was created'
  end
end
