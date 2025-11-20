# frozen_string_literal: true

module Api
  module V1
    class TagSchema < Apiwork::Schema::Base
      attribute :id
      attribute :name
      attribute :slug
      attribute :created_at
      attribute :updated_at
    end
  end
end
