# frozen_string_literal: true

module MightyWolf
  class VehicleRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :type, filterable: true
    attribute :brand, filterable: true, writable: true
    attribute :model, filterable: true, writable: true
    attribute :year, filterable: true, sortable: true, writable: true
    attribute :color, writable: true
    attribute :created_at
    attribute :updated_at
  end
end
