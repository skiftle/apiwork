# frozen_string_literal: true

module Api
  module V1
    class RestrictedInvoiceContract < Apiwork::Contract::Base
      representation RestrictedInvoiceRepresentation
    end
  end
end
