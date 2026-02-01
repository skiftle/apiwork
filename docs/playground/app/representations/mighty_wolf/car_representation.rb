# frozen_string_literal: true

module MightyWolf
  class CarRepresentation < VehicleRepresentation
    sti_name :car

    attribute :doors, writable: true
  end
end
