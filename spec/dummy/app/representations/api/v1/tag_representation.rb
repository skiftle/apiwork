# frozen_string_literal: true

module Api
  module V1
    class TagRepresentation < ApplicationRepresentation
      attribute :created_at
      attribute :id
      attribute :name
      attribute :slug
      attribute :updated_at
    end
  end
end
