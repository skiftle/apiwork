# frozen_string_literal: true

module GentleOwl
  class ImageRepresentation < Apiwork::Representation::Base
    type_name :image

    attribute :id
    attribute :title, filterable: true, writable: true
    attribute :url, writable: true
    attribute :width, writable: true
    attribute :height, writable: true
    attribute :created_at, sortable: true

    has_many :comments
  end
end
