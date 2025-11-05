# frozen_string_literal: true

module Api
  module V1
    # ArticleResource - Minimal representation of Post model
    # Demonstrates how the same model can have multiple resource representations
    class ArticleResource < Apiwork::Resource::Base
      model Post
      root :article

      attribute :id
      attribute :title
      # Intentionally excludes body and published fields
      # to show selective attribute exposure

      # Comments association with sortable: false for testing error handling
      has_many :comments, class_name: 'Api::V1::CommentResource', sortable: false
    end
  end
end
