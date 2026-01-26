# frozen_string_literal: true

module Api
  module V1
    class ServiceRepresentation < Apiwork::Representation::Base
      attribute :name
      attribute :description

      belongs_to :client
    end
  end
end
