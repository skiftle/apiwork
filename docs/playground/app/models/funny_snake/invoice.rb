# frozen_string_literal: true

module FunnySnake
  class Invoice < ApplicationRecord
    enum :status, draft: 'draft', sent: 'sent', paid: 'paid'

    validates :number, presence: true
  end
end
