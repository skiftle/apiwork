# frozen_string_literal: true

module Api
  module OverrideTest
    class InvoiceRepresentation < Apiwork::Representation::Base
      model Invoice

      attribute :id
      attribute :number, writable: true
      attribute :status
    end
  end
end
