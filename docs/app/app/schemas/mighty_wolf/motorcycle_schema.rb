# frozen_string_literal: true

module MightyWolf
  class MotorcycleSchema < VehicleSchema
    model Motorcycle
    variant as: :motorcycle

    attribute :engine_cc, writable: true
  end
end
