# frozen_string_literal: true

module HappyZebra
  class UserSchema < Apiwork::Schema::Base
    attribute :id
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
    attribute :email, writable: true, filterable: true
    attribute :username, writable: true, filterable: true

    has_one :profile, writable: true, include: :always
  end
end
