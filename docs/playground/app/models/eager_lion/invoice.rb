# frozen_string_literal: true

module EagerLion
  class Invoice < ApplicationRecord
    belongs_to :customer
    has_many :lines, dependent: :destroy

    enum :status, { draft: 0, sent: 1, paid: 2 }

    validates :number, presence: true
  end
end
