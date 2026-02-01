# frozen_string_literal: true

module MightyWolf
  class TruckRepresentation < VehicleRepresentation
    type_name :truck

    attribute :payload_capacity, writable: true
  end
end
