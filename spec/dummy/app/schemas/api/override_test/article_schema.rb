# frozen_string_literal: true

module Api
  module OverrideTest
    class ArticleSchema < Apiwork::Schema::Base
      model Post

      attribute :id
      attribute :title
      attribute :body
      attribute :published
    end
  end
end
