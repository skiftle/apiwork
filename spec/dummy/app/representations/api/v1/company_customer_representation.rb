# frozen_string_literal: true

module Api
  module V1
    class CompanyCustomerRepresentation < CustomerRepresentation
      type_name :company

      attribute :industry, writable: true
      attribute :registration_number, writable: true
    end
  end
end
