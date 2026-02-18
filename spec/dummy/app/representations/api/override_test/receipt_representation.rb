# frozen_string_literal: true

module Api
  module OverrideTest
    class ReceiptRepresentation < ApplicationRepresentation
      model Invoice
      root :receipt

      attribute :id
      attribute :number
    end
  end
end
