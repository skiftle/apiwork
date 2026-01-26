# frozen_string_literal: true

module MightyWolf
  class MotorcycleRepresentation < VehicleRepresentation
    type_name :motorcycle

    attribute :engine_cc, writable: true
  end
end
