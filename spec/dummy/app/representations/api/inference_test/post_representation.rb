# frozen_string_literal: true

module Api
  module InferenceTest
    class PostRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :title
      attribute :body
      attribute :published
    end
  end
end
