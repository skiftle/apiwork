# frozen_string_literal: true

module EagerLion
  class Invoice < ApplicationRecord
    belongs_to :customer
    has_many :lines, dependent: :destroy

    accepts_nested_attributes_for :lines, allow_destroy: true

    enum :status, draft: 'draft', sent: 'sent', paid: 'paid'

    validates :number, presence: true
  end
end
