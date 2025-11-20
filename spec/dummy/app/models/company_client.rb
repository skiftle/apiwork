# frozen_string_literal: true

class CompanyClient < Client
  validates :industry, presence: true
end
