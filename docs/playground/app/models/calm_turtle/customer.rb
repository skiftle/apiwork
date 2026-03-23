# frozen_string_literal: true

module CalmTurtle
  class Customer < ApplicationRecord
    validates :name, presence: true
  end
end
