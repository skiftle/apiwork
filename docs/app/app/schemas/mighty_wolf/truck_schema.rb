# frozen_string_literal: true

module MightyWolf
  class TruckSchema < VehicleSchema
    model Truck
    variant as: :truck

    attribute :payload_capacity, writable: true
  end
end
