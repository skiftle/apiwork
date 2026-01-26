# frozen_string_literal: true

module Api
  module OverrideTest
    class ArticleRepresentation < Apiwork::Representation::Base
      model Post

      attribute :id
      attribute :title
      attribute :body
      attribute :published
    end
  end
end
