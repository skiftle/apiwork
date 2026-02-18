# frozen_string_literal: true

module Api
  module V1
    class ServiceRepresentation < ApplicationRepresentation
      attribute :description
      attribute :name

      belongs_to :customer
    end
  end
end
