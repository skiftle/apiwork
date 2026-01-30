# frozen_string_literal: true

module Api
  module V1
    class ProfileRepresentation < Apiwork::Representation::Base
      description 'User profile with personal settings'
      example({ bio: 'Software developer', timezone: 'Europe/Stockholm' })
      deprecated!

      attribute :id, filterable: true, sortable: true
      attribute :bio, writable: true, nullable: true
      attribute :avatar_url, writable: true, nullable: true
      attribute :timezone, writable: true
      attribute :external_id, filterable: true, format: :uuid
      attribute :balance, filterable: true, sortable: true
      attribute :preferred_contact_time, filterable: true, sortable: true
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true

      belongs_to :user
    end
  end
end
