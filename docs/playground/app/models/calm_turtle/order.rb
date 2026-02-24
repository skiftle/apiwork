# frozen_string_literal: true

module CalmTurtle
  class Order < ApplicationRecord
    belongs_to :customer

    validates :order_number, presence: true
  end
end
