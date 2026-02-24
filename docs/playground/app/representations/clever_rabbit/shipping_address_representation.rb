# frozen_string_literal: true

module CleverRabbit
  class ShippingAddressRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :street, writable: true
    attribute :city, writable: true
    attribute :postal_code, writable: true
    attribute :country, writable: true
  end
end
