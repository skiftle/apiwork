# frozen_string_literal: true

module BoldFalcon
  class ArticleSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, filterable: true, writable: true
    attribute :body, writable: true
    attribute :status, filterable: true, sortable: true, writable: true
    attribute :view_count, filterable: true, sortable: true
    attribute :rating, filterable: true, sortable: true
    attribute :published_on, filterable: true, sortable: true, writable: true
    attribute :created_at, sortable: true
    attribute :updated_at

    belongs_to :category, filterable: true
  end
end
