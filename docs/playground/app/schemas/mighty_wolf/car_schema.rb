# frozen_string_literal: true

module MightyWolf
  class CarSchema < VehicleSchema
    variant as: :car

    attribute :doors, writable: true
  end
end
