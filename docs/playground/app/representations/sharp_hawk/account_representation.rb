# frozen_string_literal: true

module SharpHawk
  class AccountRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :email, writable: :create
    attribute :name, writable: true
    attribute :role, writable: :update
    attribute :verified, writable: :update
    attribute :created_at
    attribute :updated_at
  end
end
