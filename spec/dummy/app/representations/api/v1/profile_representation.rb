# frozen_string_literal: true

module Api
  module V1
    class ProfileRepresentation < Apiwork::Representation::Base
      description 'Billing profile with personal settings'
      example({ name: 'Admin', email: 'admin@billing.test', timezone: 'Europe/Stockholm' })
      deprecated!

      attribute :id, filterable: true, sortable: true
      attribute :name, writable: true
      attribute :email, writable: true
      attribute :bio, writable: true, nullable: true
      attribute :timezone, writable: true
      attribute :external_id, filterable: true, format: :uuid
      attribute :balance, filterable: true, sortable: true
      attribute :preferred_contact_time, filterable: true, sortable: true
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true
    end
  end
end
