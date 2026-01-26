# frozen_string_literal: true

module MightyWolf
  class MotorcycleRepresentation < VehicleRepresentation
    variant as: :motorcycle

    attribute :engine_cc, writable: true
  end
end
