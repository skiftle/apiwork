# frozen_string_literal: true

module MightyWolf
  class MotorcycleRepresentation < VehicleRepresentation
    sti_name :motorcycle

    attribute :engine_cc, writable: true
  end
end
