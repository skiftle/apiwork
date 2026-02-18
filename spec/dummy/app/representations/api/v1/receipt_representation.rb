# frozen_string_literal: true

module Api
  module V1
    class ReceiptRepresentation < Apiwork::Representation::Base
      model Invoice
      root :receipt
      description 'A billing receipt'
      example({ id: 1, number: 'INV-001' })

      attribute :id, filterable: true, sortable: true
      attribute :number, filterable: true, sortable: true

      has_many :items
    end
  end
end
