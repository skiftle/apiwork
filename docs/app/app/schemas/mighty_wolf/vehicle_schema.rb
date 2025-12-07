# frozen_string_literal: true

module MightyWolf
  class VehicleSchema < Apiwork::Schema::Base
    discriminator :kind

    attribute :id
    attribute :brand, writable: true, filterable: true
    attribute :model, writable: true, filterable: true
    attribute :year, writable: true, filterable: true, sortable: true
    attribute :color, writable: true
  end
end
