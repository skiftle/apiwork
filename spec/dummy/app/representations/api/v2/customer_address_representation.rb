# frozen_string_literal: true

module Api
  module V2
    class CustomerAddressRepresentation < ApplicationRepresentation
      model Address

      attribute :city, writable: true
      attribute :country, writable: true
      attribute :created_at
      attribute :id
      attribute :street, writable: true
      attribute :updated_at
      attribute :zip, writable: true
    end
  end
end
