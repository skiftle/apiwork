# frozen_string_literal: true

module MightyWolf
  class MotorcycleSchema < VehicleSchema
    variant :motorcycle

    attribute :engine_cc, writable: true
  end
end
