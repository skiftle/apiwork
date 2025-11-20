# frozen_string_literal: true

module Api
  module V1
    class ClientSchema < Apiwork::Schema::Base
      discriminator as: :kind

      attribute :name
      attribute :email

      has_many :services
    end
  end
end
