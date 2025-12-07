# frozen_string_literal: true

module CleverRabbit
  class LineItem < ApplicationRecord
    self.table_name = 'clever_rabbit_line_items'

    belongs_to :order

    validates :product_name, presence: true
  end
end
