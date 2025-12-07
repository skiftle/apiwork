# frozen_string_literal: true

module MightyWolf
  class MotorcycleSchema < VehicleSchema
    variant

    attribute :engine_cc, writable: true
  end
end
