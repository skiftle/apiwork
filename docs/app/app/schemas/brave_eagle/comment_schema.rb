# frozen_string_literal: true

module BraveEagle
  class CommentSchema < Apiwork::Schema::Base
    description 'A comment on a task'

    attribute :id,
              description: 'Unique comment identifier'

    attribute :body, writable: true,
                     description: 'Comment content',
                     example: 'This looks good, ready for review.'

    attribute :author_name, writable: true,
                            description: 'Name of the person who wrote the comment',
                            example: 'John Doe'

    attribute :created_at,
              description: 'When the comment was created'
  end
end
