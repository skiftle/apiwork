# frozen_string_literal: true

module GentleOwl
  class PostRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :title, filterable: true, writable: true
    attribute :body, writable: true
    attribute :created_at, sortable: true

    has_many :comments
  end
end
