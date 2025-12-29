# frozen_string_literal: true

module GentleOwl
  class ImageSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, filterable: true, writable: true
    attribute :url, writable: true
    attribute :width, writable: true
    attribute :height, writable: true
    attribute :created_at, sortable: true

    has_many :comments
  end
end
