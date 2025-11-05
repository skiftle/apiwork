# frozen_string_literal: true

module Api
  module V1
    class CommentResource < Apiwork::Resource::Base
      model Comment

      attribute :id, filterable: true, sortable: true
      attribute :content, writable: true, filterable: true, sortable: true
      attribute :author, writable: true, filterable: true, sortable: true
      attribute :post_id, writable: true
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true

      belongs_to :post, class_name: 'Api::V1::PostResource', filterable: true, sortable: true

    end
  end
end
