# frozen_string_literal: true

module Api
  module V1
    class AddressContract < Apiwork::Contract::Base
      representation AddressRepresentation
    end
  end
end
