# frozen_string_literal: true

module CleverRabbit
  class LineItemSchema < Apiwork::Schema::Base
    attribute :id
    attribute :product_name, writable: true
    attribute :quantity, writable: true
    attribute :unit_price, writable: true
  end
end
