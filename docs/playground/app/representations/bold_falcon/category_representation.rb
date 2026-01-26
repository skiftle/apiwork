# frozen_string_literal: true

module BoldFalcon
  class CategoryRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :name, filterable: true
    attribute :slug, filterable: true
  end
end
