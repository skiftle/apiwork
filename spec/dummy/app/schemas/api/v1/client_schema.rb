# frozen_string_literal: true

module Api
  module V1
    class ClientSchema < Apiwork::Schema::Base
      discriminated! as: :kind

      attribute :name, writable: true
      attribute :email, writable: true

      has_many :services
    end
  end
end
