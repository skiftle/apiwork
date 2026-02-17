# frozen_string_literal: true

module Api
  module V1
    class AddressRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :street, writable: true
      attribute :city, writable: true
      attribute :zip, writable: true
      attribute :country, writable: true
      attribute :created_at
      attribute :updated_at

      belongs_to :customer
    end
  end
end
