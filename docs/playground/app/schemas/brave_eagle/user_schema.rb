# frozen_string_literal: true

module BraveEagle
  class UserSchema < Apiwork::Schema::Base
    description 'A user who can be assigned to tasks'

    attribute :id, description: 'Unique user identifier'

    attribute :name, description: "User's display name", example: 'Jane Doe'

    attribute :email, description: "User's email address", example: 'jane@example.com', format: :email
  end
end
