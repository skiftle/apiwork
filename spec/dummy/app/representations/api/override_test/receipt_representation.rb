# frozen_string_literal: true

module Api
  module OverrideTest
    class ReceiptRepresentation < Apiwork::Representation::Base
      model Invoice
      root :receipt

      attribute :id
      attribute :number
    end
  end
end
