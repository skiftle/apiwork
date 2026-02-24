# frozen_string_literal: true

module HappyZebra
  class ProfileRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :bio, writable: true
    attribute :website, writable: true
    attribute :created_at
    attribute :updated_at

    belongs_to :user
  end
end
