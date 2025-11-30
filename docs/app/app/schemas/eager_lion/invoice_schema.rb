# frozen_string_literal: true

module EagerLion
  class InvoiceSchema < Apiwork::Schema::Base
    attribute :id
    attribute :created_at, sortable: true
    attribute :updated_at, sortable: true
    attribute :number, writable: true, filterable: true
    attribute :issued_on, writable: true, sortable: true
    attribute :notes, writable: true
    attribute :status, filterable: true, sortable: true

    has_many :lines, schema: LineSchema, writable: true, include: :always
    belongs_to :customer, schema: CustomerSchema, include: :always
  end
end
