# frozen_string_literal: true

module Api
  module V1
    class ArticleSchema < Apiwork::Schema::Base
      model Post
      root :article
      description 'A news article'
      example({ id: 1, title: 'Breaking News' })

      attribute :id, filterable: true, sortable: true
      attribute :title, filterable: true, sortable: true
      # Intentionally excludes body and published fields
      # to show selective attribute exposure

      # Comments association with sortable: false for testing error handling
      has_many :comments, schema: CommentSchema, sortable: false
    end
  end
end
