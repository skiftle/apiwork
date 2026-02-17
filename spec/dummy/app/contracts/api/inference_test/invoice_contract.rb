# frozen_string_literal: true

module Api
  module InferenceTest
    class InvoiceContract < Apiwork::Contract::Base
      representation InvoiceRepresentation
    end
  end
end
