# frozen_string_literal: true

module Api
  module OverrideTest
    class PostRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :title, filterable: true
      attribute :body
      attribute :published
    end
  end
end
