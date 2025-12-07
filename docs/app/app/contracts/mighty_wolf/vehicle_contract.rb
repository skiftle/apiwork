# frozen_string_literal: true

module MightyWolf
  class VehicleContract < Apiwork::Contract::Base
    schema!

    register_sti_variants CarSchema, MotorcycleSchema, TruckSchema
  end
end
