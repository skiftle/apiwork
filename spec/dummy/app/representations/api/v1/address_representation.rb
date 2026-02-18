# frozen_string_literal: true

module Api
  module V1
    class AddressRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :street, description: 'Street address line', writable: :create
      attribute :city, writable: true
      attribute :zip, writable: true
      attribute :country, deprecated: true, example: 'SE', writable: :update
      attribute :created_at
      attribute :updated_at

      belongs_to :customer, include: :always
    end
  end
end
