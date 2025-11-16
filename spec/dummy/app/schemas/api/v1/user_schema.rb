# frozen_string_literal: true

module Api
  module V1
    # UserSchema - Tests auto-detection with abstract base class
    # Inherits from BaseSchema (abstract) and should auto-detect User model
    class UserSchema < BaseSchema
      attribute :id, filterable: true, sortable: true
      attribute :email, writable: true, filterable: true, sortable: true, nullable: true
      attribute :name, writable: true, filterable: true, sortable: true, empty: true
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true
    end
  end
end
