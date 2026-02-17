# frozen_string_literal: true

module Api
  module V1
    class PaymentContract < Apiwork::Contract::Base
      representation PaymentRepresentation
    end
  end
end
