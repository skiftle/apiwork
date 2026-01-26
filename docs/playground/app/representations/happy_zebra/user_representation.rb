# frozen_string_literal: true

module HappyZebra
  class UserRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
    attribute :email, filterable: true, writable: true
    attribute :username, filterable: true, writable: true

    has_one :profile, include: :always, representation: ProfileRepresentation, writable: true
    has_many :posts, include: :always, representation: PostRepresentation, writable: true
  end
end
