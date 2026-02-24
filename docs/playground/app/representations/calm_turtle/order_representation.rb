# frozen_string_literal: true

module CalmTurtle
  class OrderRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :order_number, filterable: true, writable: true
    attribute :customer_id, writable: true
    attribute :shipping_street, writable: true
    attribute :shipping_city, writable: true
    attribute :shipping_country, writable: true
    attribute :created_at
    attribute :updated_at
  end
end
