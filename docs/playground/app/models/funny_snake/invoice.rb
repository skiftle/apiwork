# frozen_string_literal: true

module FunnySnake
  class Invoice < ApplicationRecord
    enum :status, { draft: 0, sent: 1, paid: 2 }

    validates :number, presence: true
  end
end
