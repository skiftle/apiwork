# frozen_string_literal: true

module EagerLion
  class Customer < ApplicationRecord
    has_many :invoices, dependent: :destroy
  end
end
