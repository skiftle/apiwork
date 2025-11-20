# frozen_string_literal: true

module Api
  module V1
    class ServiceSchema < Apiwork::Schema::Base
      attribute :name
      attribute :description

      belongs_to :client
    end
  end
end
