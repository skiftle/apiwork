# frozen_string_literal: true

module Api
  module V1
    class PersonCustomerContract < Apiwork::Contract::Base
      representation PersonCustomerRepresentation
    end
  end
end
