# frozen_string_literal: true

module Api
  module V1
    class CommentResource < Apiwork::Resource::Base
      model Comment

      with_options filterable: true, sortable: true do
        attribute :id
        attribute :content
        attribute :author
        attribute :created_at
        attribute :updated_at
      end

      belongs_to :post, class_name: 'Api::V1::PostResource', filterable: true, sortable: true

    end
  end
end
