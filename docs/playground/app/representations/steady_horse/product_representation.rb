# frozen_string_literal: true

module SteadyHorse
  class ProductRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :name, filterable: true, writable: true
    attribute :price, sortable: true, writable: true
    attribute :category, filterable: true, writable: true
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
  end
end
