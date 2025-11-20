# frozen_string_literal: true

class PersonClient < Client
  validates :email, presence: true
end
