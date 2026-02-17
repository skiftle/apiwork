# frozen_string_literal: true

module Api
  module V1
    class CompanyCustomerContract < Apiwork::Contract::Base
      representation CompanyCustomerRepresentation
    end
  end
end
