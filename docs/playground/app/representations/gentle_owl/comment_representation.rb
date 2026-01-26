# frozen_string_literal: true

module GentleOwl
  class CommentRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :body, writable: true
    attribute :author_name, writable: true
    attribute :created_at, sortable: true

    belongs_to :commentable, polymorphic: %i[post video image]
  end
end
