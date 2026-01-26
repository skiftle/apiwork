# frozen_string_literal: true

module MightyWolf
  class TruckRepresentation < VehicleRepresentation
    variant as: :truck

    attribute :payload_capacity, writable: true
  end
end
