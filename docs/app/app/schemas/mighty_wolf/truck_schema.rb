# frozen_string_literal: true

module MightyWolf
  class TruckSchema < VehicleSchema
    variant

    attribute :payload_capacity, writable: true
  end
end
