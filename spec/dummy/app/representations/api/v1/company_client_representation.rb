# frozen_string_literal: true

module Api
  module V1
    class CompanyClientRepresentation < ClientRepresentation
      model CompanyClient
      variant as: :company

      attribute :industry, writable: true
      attribute :registration_number, writable: true
    end
  end
end
