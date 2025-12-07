# frozen_string_literal: true

module GentleOwl
  class CommentSchema < Apiwork::Schema::Base
    attribute :id
    attribute :body, writable: true
    attribute :author_name, writable: true
    attribute :commentable_type, writable: true, filterable: true
    attribute :commentable_id, writable: true
    attribute :created_at, sortable: true
  end
end
