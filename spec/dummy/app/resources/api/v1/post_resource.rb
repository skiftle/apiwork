# frozen_string_literal: true

module Api
  module V1
    class PostResource < Apiwork::Resource::Base
      model Post

      with_options filterable: true, sortable: true do
        attribute :id
        attribute :created_at
        attribute :updated_at

        with_options writable: true do
          attribute :title
          attribute :body
          attribute :published
        end
      end

      has_many :comments, class_name: 'Api::V1::CommentResource', writable: true, filterable: true, sortable: true, serializable: false
    end
  end
end
