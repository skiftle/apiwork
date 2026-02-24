# frozen_string_literal: true

module LoyalHound
  class BookRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :title, filterable: true, writable: true
    attribute :published_on, sortable: true, writable: true
    attribute :author_id, writable: true
    attribute :created_at
    attribute :updated_at

    belongs_to :author
    has_many :reviews
  end
end
