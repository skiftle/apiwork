# frozen_string_literal: true

module CalmTurtle
  class Order < ApplicationRecord
    validates :order_number, presence: true
  end
end
