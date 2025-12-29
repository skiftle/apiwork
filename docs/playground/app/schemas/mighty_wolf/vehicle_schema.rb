# frozen_string_literal: true

module MightyWolf
  class VehicleSchema < Apiwork::Schema::Base
    discriminator

    attribute :id
    attribute :brand, filterable: true, writable: true
    attribute :model, filterable: true, writable: true
    attribute :year,
              filterable: true,
              sortable: true,
              writable: true
    attribute :color, writable: true
  end
end
