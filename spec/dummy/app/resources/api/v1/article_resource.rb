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
    end
  end
end
