# frozen_string_literal: true

module CleverRabbit
  class LineItem < ApplicationRecord
    belongs_to :order

    validates :product_name, presence: true
  end
end
