# frozen_string_literal: true

module MightyWolf
  class CarSchema < VehicleSchema
    variant

    attribute :doors, writable: true
  end
end
