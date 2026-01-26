# frozen_string_literal: true

module MightyWolf
  class CarRepresentation < VehicleRepresentation
    variant as: :car

    attribute :doors, writable: true
  end
end
