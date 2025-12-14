# frozen_string_literal: true

module FunnySnake
  class Invoice < ApplicationRecord
    validates :number, presence: true
  end
end
