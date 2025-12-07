# frozen_string_literal: true

module GentleOwl
  class VideoSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, writable: true, filterable: true
    attribute :url, writable: true
    attribute :duration, writable: true
    attribute :created_at, sortable: true

    has_many :comments
  end
end
