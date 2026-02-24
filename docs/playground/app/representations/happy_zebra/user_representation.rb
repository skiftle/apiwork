# frozen_string_literal: true

module HappyZebra
  class UserRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :email, filterable: true, writable: true
    attribute :username, filterable: true, writable: true
    attribute :created_at
    attribute :updated_at

    has_one :profile, include: :always, writable: true
    has_many :posts, include: :always, writable: true
  end
end
