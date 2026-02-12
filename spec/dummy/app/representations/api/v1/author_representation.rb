# frozen_string_literal: true

module Api
  module V1
    # AuthorRepresentation - Test schema for writable context filtering
    class AuthorRepresentation < Apiwork::Representation::Base
      model Author

      attribute :id, filterable: true, sortable: true

      # name is writable on both create and update
      attribute :name, filterable: true, sortable: true, writable: true

      # bio is only writable on create
      attribute :bio, writable: :create

      # verified is only writable on update
      attribute :verified, writable: :update

      attribute :created_at
      attribute :updated_at
    end
  end
end
