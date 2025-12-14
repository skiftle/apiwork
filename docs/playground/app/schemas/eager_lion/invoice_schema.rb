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
    attribute :customer_id, writable: true

    has_many :lines, writable: true, include: :always
    belongs_to :customer, include: :always
  end
end
