# frozen_string_literal: true

module Api
  module V1
    class CompanyClientSchema < ClientSchema
      model CompanyClient
      variant as: "company"

      attribute :industry
      attribute :registration_number
    end
  end
end
