# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :customer

  enum :method, { credit_card: 0, bank_transfer: 1, cash: 2 }
  enum :status, { pending: 0, completed: 1, failed: 2, refunded: 3 }
end
