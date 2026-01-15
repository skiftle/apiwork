# frozen_string_literal: true

module Api
  module V1
    class CompanyClientSchema < ClientSchema
      model CompanyClient
      variant :company

      attribute :industry, writable: true
      attribute :registration_number, writable: true
    end
  end
end
