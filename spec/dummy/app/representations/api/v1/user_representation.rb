# frozen_string_literal: true

module Api
  module V1
    # UserRepresentation - Tests auto-detection with abstract base class
    # Inherits from BaseRepresentation (abstract) and should auto-detect User model
    class UserRepresentation < BaseRepresentation
      attribute :id, filterable: true, sortable: true
      attribute :email,
                writable: true,
                filterable: true,
                sortable: true,
                nullable: true,
                encode: ->(value) { value&.downcase },
                decode: ->(value) { value&.upcase }
      attribute :name, writable: true, filterable: true, sortable: true, empty: true, min: 2, max: 50
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true

      has_one :profile, include: :optional
    end
  end
end
