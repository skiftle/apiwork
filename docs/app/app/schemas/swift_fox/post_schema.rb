# frozen_string_literal: true

module SwiftFox
  class PostSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, writable: true, filterable: true
    attribute :body, writable: true
    attribute :status, writable: true, filterable: true, sortable: true
    attribute :created_at, sortable: true
    attribute :updated_at
  end
end
