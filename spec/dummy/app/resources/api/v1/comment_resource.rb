# frozen_string_literal: true

module Api
  module V1
    class CommentResource < Apiwork::Resource::Base
      model Comment

      attribute :content, :string
      attribute :author, :string
      attribute :created_at, :datetime
      attribute :updated_at, :datetime

      association :post, resource: 'Api::V1::PostResource'
    end
  end
end
