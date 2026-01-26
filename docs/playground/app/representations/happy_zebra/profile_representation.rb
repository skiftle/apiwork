# frozen_string_literal: true

module HappyZebra
  class ProfileRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
    attribute :bio, writable: true
    attribute :website, writable: true

    belongs_to :user
  end
end
