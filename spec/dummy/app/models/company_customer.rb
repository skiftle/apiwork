# frozen_string_literal: true

class CompanyCustomer < Customer
  validates :industry, presence: true
end
