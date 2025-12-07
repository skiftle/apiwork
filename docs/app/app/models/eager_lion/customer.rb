# frozen_string_literal: true

module EagerLion
  class Customer < ApplicationRecord
    self.table_name = 'eager_lion_customers'

    has_many :invoices, dependent: :destroy
  end
end
