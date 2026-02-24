# frozen_string_literal: true

module CalmTurtle
  class CustomerRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :name, filterable: true, writable: true
    attribute :billing_street, writable: true
    attribute :billing_city, writable: true
    attribute :billing_country, writable: true
    attribute :created_at
    attribute :updated_at
  end
end
