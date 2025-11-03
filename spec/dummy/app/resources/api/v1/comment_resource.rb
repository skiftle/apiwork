# frozen_string_literal: true

module Api
  module V1
    class CommentResource < Apiwork::Resource::Base
      model Comment

      attribute :id
      attribute :content
      attribute :author
      attribute :created_at
      attribute :updated_at

      belongs_to :post, resource: 'Api::V1::PostResource'
    end
  end
end
