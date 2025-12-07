# frozen_string_literal: true

module BoldFalcon
  class ArticleSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, writable: true, filterable: true
    attribute :body, writable: true
    attribute :status, writable: true, filterable: true, sortable: true
    attribute :view_count, filterable: true, sortable: true
    attribute :rating, filterable: true, sortable: true
    attribute :published_on, writable: true, filterable: true, sortable: true
    attribute :created_at, sortable: true
    attribute :updated_at

    belongs_to :category, filterable: true
  end
end
