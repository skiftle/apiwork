# frozen_string_literal: true

module SharpHawk
  class Account < ApplicationRecord
    validates :email, :name, presence: true
  end
end
