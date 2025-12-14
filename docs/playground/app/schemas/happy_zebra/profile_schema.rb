# frozen_string_literal: true

module HappyZebra
  class ProfileSchema < Apiwork::Schema::Base
    attribute :id
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
    attribute :bio, writable: true
    attribute :website, writable: true

    belongs_to :user
  end
end
