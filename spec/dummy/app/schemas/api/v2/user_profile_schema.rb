# frozen_string_literal: true

module Api
  module V2
    class UserProfileSchema < Apiwork::Schema::Base
      model UserProfile

      attribute :id
      attribute :bio, writable: true, nullable: true
      attribute :avatar_url, writable: true, nullable: true
      attribute :timezone, writable: true
      attribute :created_at
      attribute :updated_at
    end
  end
end
