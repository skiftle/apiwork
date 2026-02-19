# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :invoice
  belongs_to :customer

  enum :method, { bank_transfer: 1, cash: 2, credit_card: 0 }
  enum :status, { completed: 1, failed: 2, pending: 0, refunded: 3 }
end
