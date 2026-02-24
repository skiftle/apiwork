# frozen_string_literal: true

module LoyalHound
  class ReviewRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :rating
    attribute :body
  end
end
