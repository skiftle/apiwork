# frozen_string_literal: true

module BoldFalcon
  class CategorySchema < Apiwork::Schema::Base
    attribute :id
    attribute :name, filterable: true
    attribute :slug, filterable: true
  end
end
