# frozen_string_literal: true

class PersonCustomer < Customer
  validates :email, presence: true
end
