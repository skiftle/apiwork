# frozen_string_literal: true

module Api
  module V2
    class CustomerAddressRepresentation < ApplicationRepresentation
      model Address

      attribute :created_at
      attribute :id
      attribute :updated_at

      with_options writable: true do
        attribute :city
        attribute :country
        attribute :street
        attribute :zip
      end
    end
  end
end
