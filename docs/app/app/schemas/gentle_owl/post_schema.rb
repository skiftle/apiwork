# frozen_string_literal: true

module GentleOwl
  class PostSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, writable: true, filterable: true
    attribute :body, writable: true
    attribute :created_at, sortable: true

    has_many :comments
  end
end
