# frozen_string_literal: true

module Api
  module V1
    class AddressRepresentation < Apiwork::Representation::Base
      attribute :city, writable: true
      attribute :country, deprecated: true, example: 'SE', writable: :update
      attribute :created_at
      attribute :id
      attribute :street, description: 'Street address line', writable: :create
      attribute :updated_at
      attribute :zip, writable: true

      belongs_to :customer, include: :always
    end
  end
end
