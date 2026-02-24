# frozen_string_literal: true

module EagerLion
  class InvoiceRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :number, filterable: true, writable: true
    attribute :issued_on, sortable: true, writable: true
    attribute :notes, writable: true
    attribute :status, filterable: true, sortable: true, writable: true
    attribute :customer_id, writable: true
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true

    has_many :lines, include: :always
    belongs_to :customer, include: :always
  end
end
