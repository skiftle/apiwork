# frozen_string_literal: true

module GentleOwl
  class VideoRepresentation < Apiwork::Representation::Base
    polymorphic_name :video

    attribute :id
    attribute :title, filterable: true, writable: true
    attribute :url, writable: true
    attribute :duration, writable: true
    attribute :created_at, sortable: true

    has_many :comments
  end
end
