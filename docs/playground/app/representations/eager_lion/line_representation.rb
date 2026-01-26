# frozen_string_literal: true

module EagerLion
  class LineRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :description, writable: true
    attribute :quantity, writable: true
    attribute :price, writable: true
  end
end
