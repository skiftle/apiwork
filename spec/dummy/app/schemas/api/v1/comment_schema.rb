# frozen_string_literal: true

module Api
  module V1
    class CommentSchema < Apiwork::Schema::Base
      attribute :id, filterable: true, sortable: true
      attribute :content, writable: true, filterable: true, sortable: true
      attribute :author, writable: true, filterable: true, sortable: true
      attribute :post_id, writable: true
      attribute :created_at, filterable: true, sortable: true
      attribute :updated_at, filterable: true, sortable: true

      belongs_to :post, schema: PostSchema, filterable: true, sortable: true
      has_many :replies, schema: ReplySchema, writable: true
    end
  end
end
