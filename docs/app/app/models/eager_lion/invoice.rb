# frozen_string_literal: true

module EagerLion
  class Invoice < ApplicationRecord
    self.table_name = "eager_lion_invoices"

    belongs_to :customer, class_name: "EagerLion::Customer"
    has_many :lines, class_name: "EagerLion::Line", dependent: :destroy

    accepts_nested_attributes_for :lines, allow_destroy: true

    validates :number, presence: true
  end
end
