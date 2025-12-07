# frozen_string_literal: true

module Api
  module OverrideTest
    class PostSchema < Apiwork::Schema::Base
      attribute :id
      attribute :title, filterable: true
      attribute :body
      attribute :published
    end
  end
end
