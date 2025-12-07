# frozen_string_literal: true

module EagerLion
  class Invoice < ApplicationRecord
    self.table_name = 'eager_lion_invoices'

    belongs_to :customer
    has_many :lines, dependent: :destroy

    accepts_nested_attributes_for :lines, allow_destroy: true

    validates :number, presence: true
  end
end
