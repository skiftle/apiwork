# frozen_string_literal: true

module Api
  module V1
    class TagRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :name
      attribute :slug
      attribute :created_at
      attribute :updated_at
    end
  end
end
