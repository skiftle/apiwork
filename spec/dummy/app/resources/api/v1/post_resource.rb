# frozen_string_literal: true

module Api
  module V1
    class PostResource < Apiwork::Resource::Base
      model Post

      attribute :title, :string
      attribute :body, :string
      attribute :published, :boolean
      attribute :created_at, :datetime
      attribute :updated_at, :datetime

      association :comments, resource: 'Api::V1::CommentResource'
    end
  end
end
