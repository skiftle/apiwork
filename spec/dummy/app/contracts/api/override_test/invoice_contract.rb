# frozen_string_literal: true

module Api
  module OverrideTest
    class InvoiceContract < Apiwork::Contract::Base
      representation InvoiceRepresentation
    end
  end
end
