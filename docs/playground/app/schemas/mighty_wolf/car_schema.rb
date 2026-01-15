# frozen_string_literal: true

module MightyWolf
  class CarSchema < VehicleSchema
    variant :car

    attribute :doors, writable: true
  end
end
