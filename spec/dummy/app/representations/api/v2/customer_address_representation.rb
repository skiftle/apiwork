# frozen_string_literal: true

module Api
  module V2
    class CustomerAddressRepresentation < Apiwork::Representation::Base
      model Address

      attribute :id
      attribute :street, writable: true
      attribute :city, writable: true
      attribute :zip, writable: true
      attribute :country, writable: true
      attribute :created_at
      attribute :updated_at
    end
  end
end
