# frozen_string_literal: true

module HappyZebra
  class UserSchema < Apiwork::Schema::Base
    attribute :id
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
    attribute :email, filterable: true, writable: true
    attribute :username, filterable: true, writable: true

    has_one :profile,
            include: :always,
            schema: ProfileSchema,
            writable: true
    has_many :posts,
             include: :always,
             schema: PostSchema,
             writable: true
  end
end
