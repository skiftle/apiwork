# frozen_string_literal: true

module Api
  module InferenceTest
    class InvoiceRepresentation < ApplicationRepresentation
      attribute :id
      attribute :number
      attribute :status
    end
  end
end
