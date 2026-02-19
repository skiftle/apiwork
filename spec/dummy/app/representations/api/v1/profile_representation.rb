# frozen_string_literal: true

module Api
  module V1
    class ProfileRepresentation < ApplicationRepresentation
      deprecated!
      description 'Billing profile with personal settings'
      example({ email: 'admin@billing.test', name: 'Admin', timezone: 'Europe/Stockholm' })

      with_options filterable: true, sortable: true do
        attribute :balance
        attribute :created_at
        attribute :id
        attribute :preferred_contact_time
        attribute :updated_at
      end

      with_options writable: true do
        attribute :bio, nullable: true
        attribute :email
        attribute :name
        attribute :timezone
      end

      attribute :external_id, filterable: true, format: :uuid
    end
  end
end
