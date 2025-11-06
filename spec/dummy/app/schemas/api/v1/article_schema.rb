# frozen_string_literal: true

module Api
  module V1
    # ArticleSchema - Minimal representation of Post model
    # Demonstrates how the same model can have multiple resource representations
    class ArticleSchema < Apiwork::Schema::Base
      model Post
      root :article

      attribute :id, filterable: true, sortable: true
      attribute :title, filterable: true, sortable: true
      # Intentionally excludes body and published fields
      # to show selective attribute exposure

      # Comments association with sortable: false for testing error handling
      has_many :comments, schema: CommentSchema, sortable: false
    end
  end
end
